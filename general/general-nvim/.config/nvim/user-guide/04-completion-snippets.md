<!-- chapter: Completion and snippets -->
[Back to the guide index](README.md)

# 14. Autocompletion (`nvim-cmp`)

Plugin: nvim-cmp. Sources: LSP, UltiSnips snippets, file paths, buffer words; in LaTeX files also omni (BibTeX/citations); in the `/` search line buffer words, in the `:` command line paths and command names. Each source is its own small plugin, listed in section 45 ("Completion sources and helpers").

| Keymap | Description |
| --- | --- |
| `<Tab>` | If menu is open: select next item. Otherwise: normal tab. |
| `<CR>` (Enter) | Confirm an item you picked with `<Tab>` / `<Ctrl-n>`; if nothing is selected it is a plain newline |
| `<Ctrl-e>` | Dismiss / close the completion menu |
| `<Esc>` | Close the completion menu |
| `<Ctrl-d>` | Scroll documentation popup up |
| `<Ctrl-f>` | Scroll documentation popup down |
| `<Ctrl-n>` / `<Ctrl-p>` | Open the menu / select the next / previous item (inserts it) |
| `<Ctrl-y>` | Confirm the selected item |
| `<Down>` / `<Up>` | Select the next / previous item without inserting it |
| `<Tab>` / `<S-Tab>` | In the `:` and `/` command line: open / move through the completion menu |

Completion labels are coloured like code (colorful-menu.nvim); match and kind colours follow the active colorscheme.

---

# 15. Snippets (`UltiSnips`)

Plugin: UltiSnips + vim-snippets. Custom snippets in `my_snippets/` directory.

| Keymap | Description |
| --- | --- |
| `<Ctrl-j>` | Expand snippet / jump to next placeholder |
| `<Ctrl-k>` | Jump to previous placeholder |

Available snippet files: `all`, `cpp`, `java`, `markdown`, `nix`, `python`, `snippets`, `tex`, `vim`

Example: in a Java buffer type `jfor`, press `<Ctrl-j>`: it expands to a loop with the first placeholder (`i`) selected:

```
for (int i = start; i < end; i++) {
    // code
}
```

Type `index` (it replaces `i` everywhere it appears), then `<Ctrl-j>` moves to the next placeholder (`start`), the next `<Ctrl-j>` to `end`, then to `// code`. The full walk-through is in section 52 (How to use snippets).

### Java snippets

Source: `my_snippets/java.snippets` (71 snippets). Each section below follows the same grouping as the snippet file.

The tables below are the quick reference. For each snippet's expanded code, the meaning of the placeholders and examples, see section 78 (Java chapter, `languages/java.md`, section 9).

Conventions (the same in every Java snippet):

- Triggers are camelCase and case-sensitive (`jPromptRead`, not `jpromptread`): pick them from the completion menu instead of typing them whole. Type `j` and read the list.
- Placeholders are generic English words naming the kind of thing to fill in (`type`, `name`, `condition`, `ExceptionType`), never hardcoded values.
- The Scanner variable is always named `input`. `fdijscanner` creates it; the other input snippets use an existing `input`.
- The one-line description is shown by nvim-cmp above the snippet body in the completion menu (scroll it with `<Ctrl-d>` / `<Ctrl-f>`); expand with `<Ctrl-j>`, jump between placeholders with `<Ctrl-j>` / `<Ctrl-k>`.
- `fdijscanner` uses the file name as the class name by default.
- When a snippet needs an import, its description names the exact import(s). The snippets do not add imports themselves, so check that the import line exists at the top of the file.
- Counterpart snippets name each other in their description (`jInterface` / `jImplements`, `jEquals` / `jHashCode`, `jComparable` / `jComparator`, `jtwrScanner` / `jtwrPrintWriter`, `jtwrObjectOut` / `jtwrObjectIn`, `jMinArray` / `jMaxArray`).

**Program skeleton and input**

| Trigger | Expands to / use it when |
| --- | --- |
| `fdijscanner` | Program skeleton with a Scanner named input (course package) |
| `jPromptRead` | Print a prompt and read a value (Type: Int, Double, Boolean, Line; import java.util.Scanner) |
| `jReadValidated` | Ask again until the input has the right type (Type: Int, Double, Boolean; import java.util.Scanner) |
| `jReadNumberThenLine` | Read a number and then a line, consuming the leftover newline (import java.util.Scanner) |
| `jReadUntilInt` | Loop reading numbers from input until a sentinel value (uses an existing Scanner named input; import java.util.Scanner) |
| `jReadUntilString` | Loop reading Strings from input until a sentinel text (uses an existing Scanner named input; import java.util.Scanner) |
| `jRandomInt` | Random int between a minimum and minimum + range - 1 |

**Arrays, matrices and collections**

| Trigger | Expands to / use it when |
| --- | --- |
| `jArrayNew` | Array created with a given size |
| `jArrayLiteral` | Array created from literal values |
| `jMinArray` | Find the minimum of an array (jMaxArray for the maximum) |
| `jMaxArray` | Find the maximum of an array (jMinArray for the minimum) |
| `jforMatrix` | Nested indexed for loops over a matrix |
| `jforeachMatrix` | Nested foreach loops over a matrix |
| `jArrayAdd` | Add an element to a fixed array with a counter (returns false when null or full) |
| `jArrayRemove` | Remove an element from a fixed array with a counter (object arrays; returns false when not found) |
| `jHashMap` | HashMap declaration (import java.util.HashMap) |
| `jTreeMap` | TreeMap (sorted by key) declaration (import java.util.TreeMap) |
| `jArrayList` | ArrayList declaration (import java.util.List, java.util.ArrayList) |
| `jHashSet` | HashSet declaration (import java.util.Set, java.util.HashSet) |
| `jforMapEntry` | Iterate over the entries of a map (import java.util.Map) |

**Control flow**

| Trigger | Expands to / use it when |
| --- | --- |
| `jfor` | Indexed for loop |
| `jforeach` | Enhanced for loop |
| `jwhile` | While loop |
| `jdowhile` | Do-while loop |
| `jif` | If statement |
| `jifelse` | If-else statement |
| `jifelif` | If-else if-else statement |
| `jtern` | Ternary conditional assigned to a variable |
| `jswitchtraditional` | Traditional switch statement with break |
| `jswitchmulti` | Traditional switch with two labels per case |
| `jswitcharrow` | Switch statement with arrow syntax |
| `jswitcharrowmulti` | Switch with arrow syntax and two labels per case |
| `jswitchyield` | Switch expression assigned to a variable |
| `jswitchyieldblock` | Switch expression with a block and yield |

**Methods**

| Trigger | Expands to / use it when |
| --- | --- |
| `jStaticMethod` | Private static method |
| `jRecursive` | Recursive method with a base case |

**Classes**

| Trigger | Expands to / use it when |
| --- | --- |
| `jClass` | Package-private class with 3 fields and a constructor (delete the extra fields) |
| `jPublicClass` | Public class with 3 private final fields and a constructor (delete the extra fields) |
| `jSubclass` | Subclass with a constructor calling super |
| `jAbstractClass` | Abstract class with one abstract method |
| `jInterface` | Interface with one method |
| `jImplements` | Class implementing an interface (the counterpart of jInterface) |
| `jToString` | toString with two fields |
| `jToStringSuper` | toString extending the superclass toString (for subclasses) |
| `jEquals` | equals using getClass (override hashCode too: jHashCode) |
| `jHashCode` | hashCode with Objects.hash (pair of jEquals; import java.util.Objects) |
| `jDefaultIfBlank` | Constructor field: use a default when a String is null or blank |
| `jDefaultIfBelowMin` | Constructor field: use a default when a number is below a minimum |
| `jRecord` | Record with two components |
| `jRecordCompact` | Record with a compact constructor for validation |
| `jEnum` | Plain enum with three constants |
| `jEnumFields` | Enum whose constants carry a value |
| `jInstanceOf` | Type test with a binding variable (pattern matching) |
| `jComparable` | compareTo method for natural ordering (add implements Comparable by hand) |
| `jComparator` | Separate Comparator class (the counterpart of jComparable; import java.util.Comparator) |

**Exceptions**

| Trigger | Expands to / use it when |
| --- | --- |
| `jException` | Custom checked exception with a fixed message |
| `jExceptionData` | Custom checked exception carrying a value |
| `jThrowIf` | Guard that throws (ExceptionType: IllegalArgumentException, NullPointerException, ...) |
| `jtrycatch` | Try-catch block |
| `jtryfinally` | Try-catch-finally block |
| `jtrywith` | Generic try-with-resources block |

**File I/O and serialization**

| Trigger | Expands to / use it when |
| --- | --- |
| `jtwrScanner` | Read a text file line by line with a Scanner (import java.util.Scanner, java.io.File, java.io.FileNotFoundException) |
| `jtwrPrintWriter` | Write to a text file with a PrintWriter (the counterpart of jtwrScanner; import java.io.PrintWriter, java.io.FileOutputStream, java.io.FileNotFoundException) |
| `jtwrBufferedReader` | Read a file with BufferedReader and readLine in a loop (import java.io.BufferedReader, java.io.FileReader, java.io.IOException) |
| `jtwrObjectOut` | Serialize an object to a file (import java.io.ObjectOutputStream, java.io.FileOutputStream, java.io.IOException) |
| `jtwrObjectIn` | Read a serialized object from a file (the counterpart of jtwrObjectOut; import java.io.ObjectInputStream, java.io.FileInputStream, java.io.IOException) |
| `jSerialUID` | serialVersionUID field for a Serializable class (class must implement java.io.Serializable) |

**JavaFX**

| Trigger | Expands to / use it when |
| --- | --- |
| `jfxApp` | JavaFX application skeleton (import javafx.application.Application, javafx.stage.Stage, javafx.scene.Scene, javafx.scene.layout.BorderPane) |
| `jfxProperty` | Model field with the JavaFX property trio (create the property in the constructor; import javafx.beans.property.StringProperty (or the property type used)) |
| `jfxAlert` | JavaFX alert dialog (AlertType: INFORMATION, WARNING, ERROR, CONFIRMATION; import javafx.scene.control.Alert, javafx.scene.control.Alert.AlertType) |
| `jfxOnAction` | JavaFX button event handler |

### Other snippets

| File | Triggers |
| --- | --- |
| all | `arw` (right arrow), `ltx` (LaTeX symbol) |
| cpp | `bare` (barebone template), `icd` (`#include`), `incvec` `incmap` `incset` `incqueue` `incstr` `incstack` (include that header), `vec` `map` `umap` `set` `uset` `queue` `stack` (std containers), `cout`, `plist` (print vector), `pmat` (print list of lists), `pqueue` (print queue), `random` (random list), `sol` (solution), `for`, `if`, `ifelse` |
| markdown | `meta` (YAML front matter), `h1` ... `h6` (header), `link`, `rlink` (reference link), `img`, `font`, `more`, `detail` (clickable details), `k1` / `kbd`, `k2`, `k3` (keyboard keys), `info` `warn` `error` `success` (boxes), `td` (too long, did not read), `yh` (corner quotes) |
| nix | `homepackages`, `systempackages`, `excludepackages`, `delibheaderhome`, `delibheadersystem`, `delibheaderhomealways`, `delibheadersystemalways`, `let`, `mkshell`, `mkderiv`, `flake`, `homefile`, `fetchgit`, `systemd` |
| python | `print`, `impa` (import as), `main` (main boilerplate), `sol` (solution) |
| snippets | `snip` (UltiSnips snippet definition) |
| tex | `use` (`\usepackage{}`), `eqa` (equation environment) |
| vim | `fun` (function), `aug` (augroup) |

Two examples (tested): in any file `arw` + `<Ctrl-j>` gives `--> ` with the cursor after the arrow. In a Python file `main` + `<Ctrl-j>` (at the start of a line) gives this block, with the cursor on the empty indented line inside `def main():`:

```
def main():
    (cursor here)


if __name__ == "__main__":
    main()
```

---

# 45. Autocompletion in depth (`nvim-cmp`)

## How it works

When you type in insert mode, **nvim-cmp** queries multiple sources and shows a popup menu with suggestions:

1. **LSP** (highest priority): Function names, variables, methods, types from the language server
2. **UltiSnips**: Snippet triggers (e.g., type `jfor` in a Java file)
3. **Path**: File paths when you start typing a path
4. **Buffer** (lowest priority, min 2 chars): Words already in the current buffer

For LaTeX files the sources are **omni** (BibTeX/citations), the texlab LSP (only when `texlab` is on PATH, LaTeX devShell), UltiSnips, buffer and path.

## The smart tab behavior

`<Tab>` has two behaviors depending on context:

1. **Completion menu is visible**: Selects the next item in the menu
2. **Otherwise**: Inserts a normal tab character

## Completion keymaps

| Keymap | In completion menu | Outside menu |
| --- | --- | --- |
| `<Tab>` | Select next item | Insert tab |
| `<CR>` (Enter) | Confirm the item you picked (with nothing picked: newline) | Insert newline |
| `<Ctrl-e>` | Close menu | Go to end of line |
| `<Esc>` | Close menu | Exit insert mode |
| `<Ctrl-d>` | Scroll docs up | Delete the character right of the cursor |
| `<Ctrl-f>` | Scroll docs down | (nothing) |

Example (tested in a Python buffer with the pyright language server): line 1 is `pri_value = 1`, and on line 2 you type `prin`. The menu opens by itself, with the language server entries first and the snippets after them:

```
prin|
+---------------------------------------+
| print             Function            |    <- from the language server
| print~            Snippet             |    <- from UltiSnips
| ProfileFunction   Variable            |
+---------------------------------------+
```

1. `<Tab>` selects the first entry: the line now reads `print`.
2. `<CR>` confirms it, and no newline is inserted.
3. If you do NOT pick an entry (no `<Tab>`) and press `<CR>`, you get a normal newline and the menu closes (it may open again on the new line when something matches there), so `<CR>` never inserts a completion you did not choose (tested: `prin` then `<CR>` left `prin` and started line 3).

## Visual indicators

- Each completion item shows an icon indicating its kind (function, variable, method, keyword, etc.) via mini.icons
- Deprecated items appear with strikethrough
- The completion menu is semi-transparent (5% blend)

## Completion sources and helpers

nvim-cmp itself only draws the menu. What it offers comes from small "source" plugins, each used under the `name` it has in `lua/config/nvim-cmp.lua`:

| Plugin | Source name | What it offers | Where it is active |
| --- | --- | --- | --- |
| `cmp-nvim-lsp` | `nvim_lsp` | Names from the language server (functions, variables, types) | Normal Insert-mode completion; first in the list (in buffers without an attached server it offers nothing) |
| `cmp-nvim-ultisnips` | `ultisnips` | Snippet triggers from UltiSnips (see "Snippets for Developers" below) | Insert-mode completion, second in the list |
| `cmp-path` | `path` | File and folder paths | Insert-mode completion; also first in the `:` command line |
| `cmp-buffer` | `buffer` | Words already in the current buffer, from 2 typed characters | Insert-mode completion (last in the list); the only source in the `/` search line |
| `cmp-omni` | `omni` | Whatever the filetype's omni-completion function offers; in LaTeX files that is vimtex (commands, labels, citations) | Only in `tex` files, where it is listed first |
| `cmp-cmdline` | `cmdline` | Ex command names and their arguments | Only in the `:` command line |

How the command line behaves: in `/` the menu offers buffer words. In `:` the `path` source is asked first and the `cmdline` source is used when it has nothing (nvim-cmp's group rule), so a path-like word completes as a path and an ordinary word as a command or argument. `<Tab>` / `<S-Tab>` open and move through the menu there (see the table in section 14).

Two helpers are not sources:

- `colorful-menu.nvim` colours each completion label the way code is coloured (name, argument list, type) using the language server's own label; the extra text (arguments, types) is drawn in the comment colour (settings in `lua/config/colorful_menu.lua`), and labels longer than 60 columns are cut. It works automatically, no keys.
- `vim-snippets` is a ready-made snippet collection loaded by UltiSnips next to the personal `my_snippets/` files (see "Ready-Made Snippets" in the snippets section below).

Libraries and dependencies of these plugins (for example `mini.icons`, which draws the kind icons) have no keys of their own.

---

# 52. Snippets for developers (`UltiSnips`)

## What snippets are

Plugin: **UltiSnips** + **vim-snippets**. Snippets are templates that expand into boilerplate code when you type a trigger word.

## Ready-made snippets (`vim-snippets`)

Besides the personal files in `my_snippets/`, UltiSnips also loads the `vim-snippets` collection: a library of common snippets for many languages that ships its own `UltiSnips/` folder. The plugin is installed as a dependency of UltiSnips and has no setup, keys or commands of its own, and the config lists the snippet folders it searches as `UltiSnips` and `my_snippets`. Its entries appear in the completion menu next to the personal ones (through the `ultisnips` source in section 45, "Completion sources and helpers"). To see what a language offers, open a file of that type, type the first letters of a common word such as `def` or `class` and look at the menu. The exact trigger list of the collection is not reproduced in this guide.

## How to use snippets

1. In insert mode, type a trigger word (e.g., `jfor` in a Java file)
2. The trigger appears in the completion menu as a snippet
3. Press `<Ctrl-j>` to expand it
4. The snippet expands with **placeholders** (highlighted fields you need to fill in)
5. Press `<Ctrl-j>` to jump to the next placeholder
6. Press `<Ctrl-k>` to jump to the previous placeholder
7. Fill in each placeholder, and you're done

Example with `jfor` in a Java buffer:

```
jfor            <- you type the trigger
(Ctrl-j)        -> for (int i = start; i < end; i++) {
                       // code
                   }                          the first placeholder, i, is selected
index           -> for (int index = start; ... typing replaces the selected placeholder everywhere it is used
(Ctrl-j)        -> the next placeholder, start, is selected; (Ctrl-j) again: end, then the body
(Ctrl-k)        -> back to the previous placeholder
```

## Custom snippets

Custom snippets live in the `my_snippets/` directory. Each file targets a specific language:

| File | Language | Notable snippets |
| --- | --- | --- |
| `all.snippets` | All filetypes | General-purpose snippets |
| `java.snippets` | Java | 71 snippets: input, arrays and collections, control flow, methods, classes, exceptions, file I/O, JavaFX (full list in section 15, Java snippets) |
| `python.snippets` | Python | Python-specific patterns |
| `cpp.snippets` | C++ | C++ templates |
| `nix.snippets` | Nix | Nix language patterns |
| `tex.snippets` | LaTeX | LaTeX environments and commands |
| `markdown.snippets` | Markdown | Markdown structures |
| `vim.snippets` | Vimscript | Vim plugin development |
| `snippets.snippets` | Snippet files | `snip`: template for a new snippet definition |

## Creating your own snippets

Edit the appropriate file in `my_snippets/` (e.g., `my_snippets/python.snippets`):

```
snippet trigger "Description" b
def ${1:function_name}(${2:args}):
    ${3:pass}
endsnippet
```

- `trigger` is what you type
- `b` means it only triggers at the beginning of a line
- `${1}`, `${2}`, `${3}` are tab-stop placeholders (jump between them with `<Ctrl-j>`)

Result (tested with exactly this definition in a Python file): typing `trigger` at the start of a line and pressing `<Ctrl-j>` gives

```
def function_name(args):
    pass
```

with the cursor on the first placeholder, `function_name`: type the real name, `<Ctrl-j>` jumps to `args`, then to `pass` (tested: `load` typed, `<Ctrl-j>`, `path` typed, `<Ctrl-j>`, `return 1` gives `def load(path):` / `    return 1`).

---
