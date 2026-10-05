<!-- chapter: C++ -->
[Back to the guide index](../README.md)

# 84. C++ (snippets, compile and run)

This chapter covers the custom C++ snippets (file `my_snippets/cpp.snippets`) and the few things the config does for C++ files. Only what is stated here has been checked in the config; the language server and the toolchain are explained in their own sections, named in "Related sections".

## What you get

| Feature | What it does | Needs |
| --- | --- | --- |
| **clangd** (language server) | Diagnostics, completion, hover and go to definition for `c` and `cpp` buffers (section 44) | `clangd` on PATH (c-cpp devShell, section 43) |
| **Compile and run** (`<Space>rf` or `<F9>`) | Compiles the file with `clang++` (else `g++`), `-Wall -Wextra -std=c++20 -O2`, and runs the binary in a split below. Only mapped when a compiler is on PATH | `clang++` or `g++` (c-cpp devShell) |
| **Run in a terminal** (`<Space>rr`) | Compiles with `g++ -Wall -Wextra -std=c++20` and runs the binary that is written next to the source (section 19) | `g++` (c-cpp devShell) |
| **Tree-sitter** | The `cpp` parser gives syntax highlighting (section 44 and the tree-sitter section of `07-code.md`) | Parser (from the nix store on Nix systems) |
| **Comment leader** | Pressing `o`, `O` or `<Enter>` after a comment line does not continue the comment (`formatoptions` without `o` and `r`) | Nothing |
| **Line-length marker** | The coloured column marker sits at column 80 for C++ (section 41) | Nothing |
| **Snippets** | See Snippets below | Nothing |

## Snippets

Source: `my_snippets/cpp.snippets`. Type the trigger in insert mode in a C++ buffer and expand it with `<Ctrl-j>` (section 15); `<Ctrl-j>` / `<Ctrl-k>` jump to the next / previous placeholder. The one-line description is shown by nvim-cmp in the completion menu. A compact trigger list is in `04-completion-snippets.md` ("Other snippets").

Conventions:

- The text in quotes after each trigger below is its description exactly as the completion menu shows it. "Start of line" snippets (UltiSnips option `b`) expand only at the beginning of a line; `w` snippets expand after a word boundary; `ifelse` expands anywhere. `$0` is the final cursor position after the last placeholder.
- `map` and `for` have the same trigger as vim-snippets entries; the personal ones override them, so you get these versions.
- Placeholders are generic English words (`type`, `name`, `condition`); in the code blocks below they are shown in tab-stop order, and a name that appears several times is typed once.
- Only the declaration snippets use unqualified names such as `vector`, so they depend on a `using` line (`bare` or an `inc...` snippet adds it). The print helpers, `cout` and `random` write `std::` in full but still need their `#include` lines, named in their descriptions.

**Group: Program skeleton and includes**

**`bare`**: "Barebone C++ program: common includes, using std:: declarations and main" (start of line). A complete starting file; the cursor ends inside `main`, on a `// code` placeholder.

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <map>
#include <unordered_map>
#include <set>
#include <unordered_set>
#include <stack>
#include <queue>
#include <numeric>
#include <algorithm>

using std::cout;
using std::endl;
using std::vector;
using std::string;
using std::map;
using std::unordered_map;
using std::set;
using std::unordered_set;
using std::stack;
using std::queue;
using std::pair;
using std::make_pair;

int main()
{
	// code
	return 0;
}
```

**`icd`**: "#include directive (start of line)". Type the header name without the brackets.

```cpp
#include <header>
```

Example: `header` = `cstdint` gives `#include <cstdint>`.

**`incvec`, `incmap`, `incset`, `incqueue`, `incstr`, `incstack`**: "Include <vector> and add using std::vector (start of line)" (and the same for `<map>`, `<set>`, `<queue>`, `<string>`, `<stack>`). They include one header and add the matching `using` line. They exist so the declaration snippets below work without `bare`. The expansion has no placeholder; `incvec` gives:

```cpp
#include <vector>

using std::vector;
```

The others are the same with `<map>` / `map`, `<set>` / `set`, `<queue>` / `queue`, `<string>` / `string`, `<stack>` / `stack`. There is no `inc` snippet for `unordered_map` and `unordered_set`; only `bare` adds their `using` lines.

**`sol`**: "LeetCode style: create a Solution object (needs a class Solution)". Creates the object that coding-challenge sites expect, then leaves the cursor below it.

```cpp
auto solution = Solution();
```

**Group: Declarations**

Each ends with `;` and leaves the cursor after it (`$0`). The description of each says what it needs, for example "std::vector declaration (needs using std::vector: bare or incvec)"; `map` adds "overrides the vim-snippets map".

| Trigger | Expands to | Needs |
| --- | --- | --- |
| `vec` | `vector<type> name;` | `bare` or `incvec` |
| `map` | `map<keyType, valueType> name;` | `bare` or `incmap` |
| `umap` | `unordered_map<keyType, valueType> name;` | `bare` (no `inc` snippet) |
| `set` | `set<type> name;` | `bare` or `incset` |
| `uset` | `unordered_set<type> name;` | `bare` (no `inc` snippet) |
| `queue` | `queue<type> name;` | `bare` or `incqueue` |
| `stack` | `stack<type> name;` | `bare` or `incstack` |

Example: `vec`, `int`, `scores` gives `vector<int> scores;`. Example: `map`, `string`, `int`, `count` gives `map<string, int> count;`.

**Group: Control flow**

**`for`** ("for loop with init, condition and step (overrides the vim-snippets for)"), **`if`** ("if statement"), **`ifelse`** ("if-else statement"): braces with the body on its own line. After the last placeholder the cursor leaves the block (`$0`).

```cpp
for (init; condition; step) {
	// code
}

if (condition) {
	// code
}

if (condition) {
	// code
} else {
	// code
}
```

Example for `for`: `int i = 0`, `i < n`, `++i`.

**Group: Printing**

**`cout`**: "Print a labelled variable with std::cout (needs #include <iostream>)".

```cpp
std::cout << "label: " << variable << std::endl;
```

Example: `label` = `total`, `variable` = `sum` gives `std::cout << "total: " << sum << std::endl;`.

**`plist`**: "print a container as [a, b, c] (needs <iostream>, <string>, <iterator>)". Defines a function template that prints any container (anything with `begin()` / `end()`) as `[a, b, c]` after a description. The description says it needs `<iostream>`, `<string>` and `<iterator>`. Put it above `main`, then call `printList(values, "values");`.

```cpp
template <class T>
void printList(const T& arr, const std::string& desc){
	std::cout << desc << ": [";

	for (auto it = arr.begin(); it != arr.end(); it++){
		std::cout << *it << ((std::next(it) != arr.end()) ? ", " : "");
	}
	std::cout << "]\n";
}
```

**`pmat`**: "print a vector of vectors, one [a, b, c] row per line (needs <iostream>, <vector>, <string>, <iterator>)". The same for a vector of vectors, one `[a, b, c]` row per line. An empty row prints `[]`. Needs `<iostream>`, `<vector>`, `<string>`, `<iterator>`. Call it as `printMat(grid, "grid");`.

```cpp
template <class T>
void printMat(const std::vector<std::vector<T>>& mat, const std::string& desc){
	std::cout << desc << ": " << std::endl;

	for (const auto& row : mat){
		std::cout << "[";
		for (auto it = row.begin(); it != row.end(); it++){
			std::cout << *it << ((std::next(it) != row.end()) ? ", " : "");
		}
		std::cout << "]\n";
	}
}
```

**`pqueue`**: "print a priority_queue or stack by popping a copy (uses top(); std::queue has front() instead)". Prints a `std::priority_queue` or `std::stack` by popping a copy, so the original stays unchanged. It uses `top()`; a `std::queue` has `front()` instead, so it does not work for `std::queue` without editing that one word. Call it as `printQueue(pq);`.

```cpp
template <class T>
void printQueue(T q){
	while(!q.empty()){
		std::cout << q.top() << " ";
		q.pop();
	}
	std::cout << '\n';
}
```

**Group: Random numbers**

**`random`**: "Function returning a vector of random ints in [low, high] (needs #include <random> and <vector>)" (start of line). A function that returns a `vector<int>` of random numbers in a range (both ends inclusive). It needs `#include <random>` and `<vector>`. It has no placeholders.

```cpp
// Generate a random sequence of length len, in range(low, high) (inclusive).
// need to #include<random>
std::vector<int> genRandom(int low, int high, int len){
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<int> distribution(low, high);

	std::vector<int> arr(len, 0);
	for (int i = 0; i != len; ++i){
		arr[i] = distribution(gen);
	}

	return arr;
}
```

## Related sections

Section 15 and 52 (snippets), 19 (code running), 41 (filetype settings), 43 (toolchain and devShells), 44 (language server in depth), 78 (Java chapter, section 9 has the same snippet layout).
