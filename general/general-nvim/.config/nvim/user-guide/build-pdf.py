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
    "07-code.md", "08-git.md", "09-ai-and-writing.md", "10-various.md",
    "languages/java.md", "languages/python.md", "languages/latex.md",
    "languages/markdown.md", "languages/typst.md",
]
CHEAT_SHEET_TITLE = "Day-to-Day Cheat Sheet"
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
            hs = [h for h in hs if h[1] != "Neovim User Guide" and h[1] != "Contents"]
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
        title = "Day-to-Day Cheat Sheet (section 2)" if rel == "README.md" else chapter_title(rel)
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
        subprocess.check_call([
            pandoc, "-f", "gfm+attributes+gfm_auto_identifiers-hard_line_breaks", "-t", "typst",
            "--standalone", "--toc", "--toc-depth=4", "--highlight-style=tango",
            "-V", "papersize=a4", "-V", "fontsize=10pt", "-V", "margin.x=1.8cm", "-V", "margin.y=2cm",
            "-V", "mainfont=DejaVu Sans", 
            "--metadata", "title=Neovim User Guide",
            "--metadata", "subtitle=Leader key: Space. Keys, commands and workflows of this config.",
            "--include-in-header", os.path.join(HERE, "pdf-header.typ"),
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


# ----------------------------------------------------------------------------- checks

def norm(s):
    s = unicodedata.normalize("NFKC", plain(s)).lower()
    return re.sub(r"[^\w]+", "", s)


def check():
    problems = []
    if open(README, encoding="utf-8").read() != readme_with_toc():
        problems.append("README.md table of contents is out of date (run ./build-pdf.py)")
    problems += check_links()
    if not os.path.exists(PDF) or not os.path.exists(STAMP):
        problems.append("neovim-user-guide.pdf is missing (run ./build-pdf.py)")
    else:
        if open(STAMP).read().strip() != sources_hash():
            problems.append("neovim-user-guide.pdf is older than the markdown (run ./build-pdf.py)")
        pdftotext = shutil.which("pdftotext")
        if pdftotext:
            text = norm(subprocess.run([pdftotext, PDF, "-"], capture_output=True, text=True).stdout)
            missing = [f"{rel}: {t}" for rel in FILES for lvl, t, _ in headings(rel)
                       if not (rel == "README.md" and lvl == 1 and t == "Neovim User Guide")
                       and not (rel == "README.md" and t in ("Contents", "2. Day-to-Day Cheat Sheet"))
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
