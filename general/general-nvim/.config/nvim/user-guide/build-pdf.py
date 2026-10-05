#!/usr/bin/env python3
"""Build and verify the Neovim user guide.

The markdown files in this folder are the source of truth. This script derives two things:

  1. the table of contents in README.md (between the toc markers), nested
     chapter > section > subsection > sub-subsection, linking to the .md files;
  2. neovim-user-guide.pdf, ONE document with a clickable table of contents, PDF bookmarks
     and working cross-references (pandoc -> typst -> pdf).

Usage:
  ./build-pdf.py           regenerate the README table of contents and the PDF
  ./build-pdf.py --check   verify only, change nothing; exit 1 when anything is stale or broken

--check verifies: README table of contents up to date, every markdown link and #anchor resolves,
the PDF was built from the current sources (stamp file), and every heading is present in the PDF
text. `<Space>?` (and the dashboard item) opens the PDF, so run the build before committing guide changes.
"""
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
PDF = os.path.join(HERE, "neovim-user-guide.pdf")
STAMP = os.path.join(HERE, "neovim-user-guide.pdf.stamp")
README = os.path.join(HERE, "README.md")
TOC_START, TOC_END = "<!-- toc:start -->", "<!-- toc:end -->"

# reading order of the chapters (README is the cheat sheet, section 2)
FILES = [
    "README.md", "01-basics.md", "02-navigation.md", "03-editing.md",
    "04-completion-snippets.md", "05-search-and-files.md", "06-windows-terminal-sessions.md",
    "07-code.md", "08-git.md", "09-ai-and-writing.md", "10-various.md", "11-plugins.md",
    "languages/java.md", "languages/python.md", "languages/latex.md",
    "languages/markdown.md", "languages/typst.md",
]
CHEAT_SHEET_TITLE = "Day-to-day cheat sheet"
TOC_DEPTH = 3  # headings # ## ### are listed in the README table of contents


def read(rel):
    with open(os.path.join(HERE, rel), encoding="utf-8") as f:
        return f.read()


def slug(text, seen):
    """GitHub heading anchor, with -1, -2 ... for repeated headings in one file."""
    s = re.sub(r"`", "", text.strip().lower())
    s = re.sub(r"[^\w\- ]", "", s, flags=re.UNICODE).replace(" ", "-")
    n = seen.get(s, 0)
    seen[s] = n + 1
    return s if n == 0 else f"{s}-{n}"


def headings(rel):
    """[(level, text, anchor)] of a file, ignoring fenced code blocks."""
    out, seen, fence = [], {}, False
    for line in read(rel).splitlines():
        if re.match(r"^\s*(```|~~~)", line):
            fence = not fence
            continue
        m = None if fence else re.match(r"^(#{1,6})\s+(.*?)\s*#*\s*$", line)
        if m:
            out.append((len(m.group(1)), m.group(2), slug(m.group(2), seen)))
    return out


def chapter_title(rel):
    if rel == "README.md":
        return CHEAT_SHEET_TITLE
    m = re.match(r"<!--\s*chapter:\s*(.*?)\s*-->", read(rel))
    if not m:
        sys.exit(f"{rel}: first line must be <!-- chapter: Title -->")
    return m.group(1)


def plain(text):
    return text.replace("`", "")


def build_toc():
    lines = []
    for i, rel in enumerate(FILES, 1):
        hs = headings(rel)
        if rel == "README.md":
            hs = [h for h in hs if h[1] != "Neovim user guide" and h[1] != "Contents"]
        else:
            lines.append("")
        lines.append(f"{i}. **[{chapter_title(rel)}]({rel})**" if rel != "README.md"
                     else f"{i}. **[{chapter_title(rel)}]({rel}#2-day-to-day-cheat-sheet)**")
        stack = []  # heading levels of the open ancestors: nesting follows the real hierarchy
        for level, text, anchor in hs:
            if level > TOC_DEPTH or (rel == "README.md" and level == 1):
                continue
            while stack and stack[-1] >= level:
                stack.pop()
            lines.append(f"{'    ' * (len(stack) + 1)}- [{plain(text)}]({rel}#{anchor})")
            stack.append(level)
    return "\n".join(lines).replace("\n\n\n", "\n\n")


def readme_with_toc():
    src = read("README.md")
    if TOC_START not in src or TOC_END not in src:
        sys.exit(f"README.md needs {TOC_START} ... {TOC_END} around the table of contents")
    head, rest = src.split(TOC_START, 1)
    _, tail = rest.split(TOC_END, 1)
    return f"{head}{TOC_START}\n\n{build_toc()}\n\n{TOC_END}{tail}"


LINK = re.compile(r"\]\(([^)\s#]*)(?:#([^)\s]*))?\)")


def check_links():
    """Every relative markdown link must hit an existing file and an existing heading."""
    errors, anchors = [], {}
    for rel in FILES:
        anchors[rel] = {a for _, _, a in headings(rel)}
    for rel in FILES:
        text = readme_with_toc() if rel == "README.md" else read(rel)
        fence = False
        for n, line in enumerate(text.splitlines(), 1):
            if re.match(r"^\s*(```|~~~)", line):
                fence = not fence
            if fence:
                continue
            line = re.sub(r"`[^`]*`", "", line)
            for m in LINK.finditer(line):
                target, frag = m.group(1), m.group(2)
                if re.match(r"^[a-z]+:", target):
                    continue
                path = rel if target == "" else os.path.normpath(
                    os.path.join(os.path.dirname(rel), target)).replace(os.sep, "/")
                if path not in anchors:
                    errors.append(f"{rel}:{n}: link to missing file {target}")
                elif frag is not None and frag not in anchors[path]:
                    errors.append(f"{rel}:{n}: no heading #{frag} in {path}")
    return errors


def sources_hash():
    h = hashlib.sha256()
    for rel in FILES:
        h.update(rel.encode())
        h.update((readme_with_toc() if rel == "README.md" else read(rel)).encode())
    for f in ("build-pdf.py", "pdf-header.typ"):
        with open(os.path.join(HERE, f), "rb") as fh:
            h.update(fh.read())
    return h.hexdigest()


# ----------------------------------------------------------------------------- PDF

def file_id(rel):
    return re.sub(r"[^a-z0-9]+", "-", rel.lower().replace(".md", "")).strip("-")


def combined_markdown():
    """One document: a chapter heading per file, every heading shifted one level down and given
    an explicit id (<file>-<anchor>), and every .md link rewritten to an in-document link."""
    ids = {rel: {a for _, _, a in headings(rel)} for rel in FILES}
    parts = []
    for i, rel in enumerate(FILES, 1):
        fid = file_id(rel)
        title = "Day-to-day cheat sheet (section 2)" if rel == "README.md" else chapter_title(rel)
        parts.append(f"# Chapter {i}: {title} {{#{fid}}}\n")
        fence, seen = False, {}
        body = readme_with_toc() if rel == "README.md" else read(rel)
        if rel == "README.md":
            # the PDF has its own generated table of contents (and no cover title)
            body = re.sub(r"\A.*?(?=^# 2\. )", "", body, flags=re.S | re.M)
        out = []
        for line in body.splitlines():
            if re.match(r"^\s*(```|~~~)", line):
                fence = not fence
            elif not fence:
                if line.startswith("<!--") or line.startswith("[Back to the guide index]"):
                    continue
                m = re.match(r"^(#{1,6})\s+(.*?)\s*#*\s*$", line)
                if m and rel == "README.md" and m.group(2).startswith("2. "):
                    seen[slug(m.group(2), seen)] = 1
                    continue  # the chapter heading above stands for it
                if m:
                    line = f"{'#' * min(len(m.group(1)) + 1, 6)} {m.group(2)} {{#{fid}--{slug(m.group(2), seen)}}}"
                else:
                    line = rewrite_links(line, rel, ids)
            out.append(line)
        parts.append("\n".join(out) + "\n")
    return "\n".join(parts)


def rewrite_links(line, rel, ids):
    def sub(m):
        target, frag = m.group(1), m.group(2)
        if re.match(r"^[a-z]+:", target):
            return m.group(0)
        path = rel if target == "" else os.path.normpath(
            os.path.join(os.path.dirname(rel), target)).replace(os.sep, "/")
        if path not in ids:
            return m.group(0)
        if path == "README.md" and frag == "2-day-to-day-cheat-sheet":
            frag = None  # that heading is the chapter heading in the PDF
        return f"](#{file_id(path)}--{frag})" if frag else f"](#{file_id(path)})"

    # leave inline code alone
    pieces = re.split(r"(`[^`]*`)", line)
    return "".join(p if p.startswith("`") else LINK.sub(sub, p) for p in pieces)


def tool(name, env_hint):
    path = shutil.which(name)
    if not path:
        sys.exit(f"{name} not found. {env_hint}")
    return path


def section_numbers():
    return {int(m.group(1)) for rel in FILES for lvl, t, _ in headings(rel) if lvl == 1
            for m in [re.match(r"(\d+)\. ", t)] if m}


def check_cover():
    """Every section number must appear exactly once in the cover's "What it covers" table."""
    src = read("README.md")
    if "**What it covers.**" not in src:
        return []
    table = src.split("**What it covers.**", 1)[1].split("\n\n**", 1)[0]
    seen = []
    for row in table.splitlines():
        cells = row.split("|")
        if len(cells) < 4 or not re.search(r"\d", cells[2]):
            continue
        for part in cells[2].split(","):
            m = re.fullmatch(r"\s*(\d+)(?: to (\d+))?\s*", part)
            if m:
                seen += range(int(m.group(1)), int(m.group(2) or m.group(1)) + 1)
    want = section_numbers()
    problems = [f"README.md cover table \"What it covers\": section {n} is missing" for n in sorted(want - set(seen))]
    problems += [f"README.md cover table \"What it covers\": section {n} listed {seen.count(n)} times"
                 for n in sorted(set(seen)) if seen.count(n) > 1 or n not in want]
    return problems


def cover_markdown():
    """The cover page text: the README top part (between the title lines and "## Contents"), so the
    README and the PDF cover share one source, plus one line of facts computed from the real files."""
    src = read("README.md")
    head = src.split("\n## Contents", 1)[0]
    head = re.sub(r"\A# .*?\n+Leader key:[^\n]*\n+", "", head, flags=re.S)  # title/subtitle come from metadata
    sections = section_numbers()
    plugins = COUNT.search(read(CATALOG))
    facts = (f"This edition: {len(sections)} numbered sections in {len(FILES)} chapters"
             + (f", {plugins.group(1)} plugins in the catalog" if plugins else "") + ".")
    return f"{head.strip()} {facts}\n"


def build_pdf():
    if not (shutil.which("pandoc") and shutil.which("typst")):
        nix = shutil.which("nix")
        if nix and not os.environ.get("USER_GUIDE_IN_NIX_SHELL"):
            env = dict(os.environ, USER_GUIDE_IN_NIX_SHELL="1")
            sys.exit(subprocess.call(
                [nix, "shell", "nixpkgs#pandoc", "nixpkgs#typst", "-c", sys.executable,
                 os.path.abspath(__file__)] + sys.argv[1:], env=env))
    pandoc = tool("pandoc", "Install pandoc and typst (or nix).")
    typst = tool("typst", "Install pandoc and typst (or nix).")
    with tempfile.TemporaryDirectory() as tmp:
        md, typ = os.path.join(tmp, "guide.md"), os.path.join(tmp, "guide.typ")
        with open(md, "w", encoding="utf-8") as f:
            f.write(combined_markdown())
        cover_md, cover_typ = os.path.join(tmp, "cover.md"), os.path.join(tmp, "cover.typ")
        with open(cover_md, "w", encoding="utf-8") as f:
            f.write(cover_markdown())
        subprocess.check_call([pandoc, "-f", "gfm", "-t", "typst", cover_md, "-o", cover_typ])
        body = open(cover_typ, encoding="utf-8").read()
        with open(cover_typ, "w", encoding="utf-8") as f:
            # 11pt text; tables a little smaller with tight padding and sized columns, so the whole cover
            # stays on page 1 (the contents must start on page 2: open_guide uses page 2)
            body = body.replace("columns: 2,", "columns: (13fr, 7fr),", 1).replace("columns: 2,", "columns: (auto, 1fr),", 1)
            f.write("#v(-2.5em)\n#[\n#set text(size: 11pt)\n#set par(justify: false, leading: 0.45em, spacing: 0.6em)\n"
                    "#set table(inset: (x: 4pt, y: 2pt))\n#show figure: set block(breakable: true)\n#show table: set text(size: 8pt)\n"
                    + body + "\n]\n")
        with open(cover_typ, "a", encoding="utf-8") as f:
            f.write("\n#pagebreak()\n")  # keeps the table of contents on page 2 (open_guide uses page 2)
        subprocess.check_call([
            pandoc, "-f", "gfm+attributes+gfm_auto_identifiers-hard_line_breaks", "-t", "typst",
            "--standalone", "--toc", "--toc-depth=4", "--highlight-style=tango",
            "-V", "papersize=a4", "-V", "fontsize=10pt", "-V", "margin.x=1.8cm", "-V", "margin.y=2cm",
            "-V", "mainfont=DejaVu Sans", 
            "--metadata", "title=Neovim user guide",
            "--metadata", "subtitle=Leader key: Space. Keys, commands and workflows of this config.",
            "--include-in-header", os.path.join(HERE, "pdf-header.typ"),
            "--include-before-body", cover_typ,
            md, "-o", typ])
        cmd = [typst, "compile"]
        for p in font_paths():
            cmd += ["--font-path", p]
        cmd += [typ, PDF]
        subprocess.check_call(cmd)
    with open(STAMP, "w") as f:
        f.write(sources_hash() + "\n")
    print(f"built {PDF}")


def font_paths():
    paths = [p for p in (
        os.path.expanduser("~/.nix-profile/share/fonts"), "/run/current-system/sw/share/X11/fonts",
        "/usr/share/fonts", os.path.expanduser("~/.local/share/fonts"),
        "/Library/Fonts", "/System/Library/Fonts") if os.path.isdir(p)]
    hm = subprocess.run(["bash", "-c", "ls -d /nix/store/*-home-manager-path/share/fonts 2>/dev/null | head -1"],
                        capture_output=True, text=True).stdout.strip()
    return paths + ([hm] if hm else [])


# ----------------------------------------------------------------------------- plugin catalog

CATALOG = "11-plugins.md"
ENTRY = re.compile(r"^\s*[-*]\s+`([^`]+)`")
COUNT = re.compile(r"<!--\s*plugin-count:\s*(\d+)\s*-->")
NVIM_DIR = os.path.dirname(HERE)


def installed_plugins():
    """Names of every plugin the config DECLARES, whether or not it is enabled on this machine:
    lazy.nvim's active plugins plus the ones it set aside as disabled (vimtex and typst.vim need
    latex/typst on PATH, vim-xkbswitch is macOS only). Using only lazy.plugins() would make the list
    depend on the environment. None when nvim is unavailable or fails (the caller then skips)."""
    nvim = shutil.which("nvim")
    if not nvim:
        return None
    with tempfile.TemporaryDirectory() as tmp:
        out = os.path.join(tmp, "plugins.txt")
        lua = ("local c=require('lazy.core.config') local t={} "
               "for k,_ in pairs(c.spec.plugins) do t[#t+1]=k end "
               "for k,_ in pairs(c.spec.disabled) do t[#t+1]=k end "
               f"local f=io.open('{out}','w') f:write(table.concat(t,'\\n')) f:close()")
        env = dict(os.environ, XDG_STATE_HOME=tmp, XDG_CACHE_HOME=tmp)
        try:
            subprocess.run([nvim, "--headless", "-u", os.path.join(NVIM_DIR, "init.lua"),
                            "-c", f"lua {lua}", "-c", "qa!"],
                           capture_output=True, text=True, timeout=120, env=env)
            names = open(out, encoding="utf-8").read().split()
        except (OSError, subprocess.SubprocessError):
            return None
    return sorted(set(names)) or None


def section_text(rel, anchor):
    """Text of the heading with this anchor, including its subsections (until the next heading
    of the same or a higher level), lowercased."""
    seen, fence, grab, level, out = {}, False, False, 0, []
    for line in read(rel).splitlines():
        if re.match(r"^\s*(```|~~~)", line):
            fence = not fence
        m = None if fence else re.match(r"^(#{1,6})\s+(.*?)\s*#*\s*$", line)
        if m:
            lvl, a = len(m.group(1)), slug(m.group(2), seen)
            if grab and lvl <= level:
                break
            if not grab and a == anchor:
                grab, level = True, lvl
        if grab:
            out.append(line)
    return "\n".join(out).lower()


def name_variants(name):
    n = name.lower()
    v = {n}
    for suf in (".nvim", ".vim", ".lua", "-nvim", "-vim"):
        if n.endswith(suf):
            v.add(n[: -len(suf)])
    if n.startswith("nvim-"):
        v.add(n[5:])
    if n.startswith("vim-"):
        v.add(n[4:])
    return {x for x in v if len(x) >= 3}


def catalog_entries():
    """{plugin name: [(file, anchor), ...]} from the bullets '- `name` ...' of 11-plugins.md; the
    links of an entry may continue on the following lines until the next bullet or heading."""
    entries, cur, fence = {}, None, False
    for line in read(CATALOG).splitlines():
        if re.match(r"^\s*(```|~~~)", line):
            fence = not fence
        if fence:
            continue
        if re.match(r"^#{1,6}\s", line):
            cur = None
        m = ENTRY.match(line)
        if m:
            cur = entries.setdefault(m.group(1), [])
        if cur is not None:
            for lm in LINK.finditer(re.sub(r"`[^`]*`", "", line)):
                target, frag = lm.group(1), lm.group(2)
                if re.match(r"^[a-z]+:", target) or frag is None:
                    continue
                path = CATALOG if target == "" else os.path.normpath(
                    os.path.join(os.path.dirname(CATALOG), target)).replace(os.sep, "/")
                cur.append((path, frag))
    return entries


def check_plugins():
    """Every plugin the config declares (enabled or not) has a catalog entry that links to a REAL in-depth section
    (outside the catalog) in which the plugin is actually mentioned; no entry for removed plugins."""
    if not os.path.exists(os.path.join(HERE, CATALOG)):
        return [f"{CATALOG} is missing (the plugin catalog)"]
    plugins = installed_plugins()
    if plugins is None:
        print("note: nvim (or lazy.nvim specs) not available, skipped the plugin catalog check")
        return []
    entries = catalog_entries()
    problems = []
    for name in plugins:
        if name not in entries:
            problems.append(f"{CATALOG}: plugin `{name}` has no catalog entry (add it, plus an in-depth section)")
            continue
        targets = [(f, a) for f, a in entries[name] if f != CATALOG and f in FILES]
        if not targets:
            problems.append(f"{CATALOG}: `{name}` has no link to an in-depth section outside the catalog")
            continue
        variants = name_variants(name)
        if not any(v in section_text(f, a) for f, a in targets for v in variants):
            problems.append(f"{CATALOG}: `{name}` is not mentioned in the section(s) it links to "
                            f"({', '.join(f'{f}#{a}' for f, a in targets)}): write the in-depth text")
    for name in sorted(set(entries) - set(plugins)):
        problems.append(f"{CATALOG}: `{name}` is listed but is not a plugin of the config (removed or renamed?)")
    m = COUNT.search(read(CATALOG))
    if not m:
        problems.append(f"{CATALOG}: add the line <!-- plugin-count: {len(plugins)} -->")
    elif int(m.group(1)) != len(plugins):
        problems.append(f"{CATALOG}: plugin-count says {m.group(1)} but the config has {len(plugins)}")
    return problems


# ----------------------------------------------------------------------------- checks

def norm(s):
    s = unicodedata.normalize("NFKC", plain(s)).lower()
    return re.sub(r"[^\w]+", "", s)


def check():
    problems = []
    if open(README, encoding="utf-8").read() != readme_with_toc():
        problems.append("README.md table of contents is out of date (run ./build-pdf.py)")
    problems += check_links()
    problems += check_plugins()
    problems += check_cover()
    if not os.path.exists(PDF) or not os.path.exists(STAMP):
        problems.append("neovim-user-guide.pdf is missing (run ./build-pdf.py)")
    else:
        if open(STAMP).read().strip() != sources_hash():
            problems.append("neovim-user-guide.pdf is older than the markdown (run ./build-pdf.py)")
        pdftotext = shutil.which("pdftotext")
        if pdftotext:
            text = norm(subprocess.run([pdftotext, PDF, "-"], capture_output=True, text=True).stdout)
            missing = [f"{rel}: {t}" for rel in FILES for lvl, t, _ in headings(rel)
                       if not (rel == "README.md" and lvl == 1 and t == "Neovim user guide")
                       and not (rel == "README.md" and t in ("Contents", "2. Day-to-day cheat sheet"))
                       and norm(t) not in text]
            problems += [f"heading missing from the PDF text: {m}" for m in missing]
            first = subprocess.run([pdftotext, "-f", "2", "-l", "2", PDF, "-"], capture_output=True, text=True).stdout
            if not first.lstrip().startswith("Contents"):
                problems.append("PDF page 2 is not the table of contents (lua/config/user-guide-tools.lua opens page 2)")
        else:
            print("note: pdftotext not found, skipped the heading-in-PDF check")
    return problems


def main():
    if "--check" in sys.argv:
        problems = check()
        for p in problems:
            print("FAIL", p)
        if problems:
            sys.exit(1)
        print("OK: README table of contents, links, and PDF all match the markdown")
        return
    new = readme_with_toc()
    if open(README, encoding="utf-8").read() != new:
        with open(README, "w", encoding="utf-8") as f:
            f.write(new)
        print("updated the README table of contents")
    errs = check_links()
    if errs:
        print("\n".join(errs))
        sys.exit("fix the broken links first")
    build_pdf()


if __name__ == "__main__":
    main()
