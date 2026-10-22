<!--no-pdf-->
# CMSC 131 Lab 2 Starter

[![lab2-checks](https://github.com/longg-anisa/cmsc-131-lab2-starter/actions/workflows/test.yml/badge.svg)](https://github.com/longg-anisa/cmsc-131-lab2-starter/actions/workflows/test.yml)

A C-callable library of sort, search, and utility routines in assembly. The manual is the assignment. This file is the repository's own notes.

## Layout

```text
Makefile       platform preamble and build rules
bench.c        provided: file I/O, timing, the C-side comparison, the hostile caller
cdecl.h        provided: the calling-convention macros
LICENSE        provided
sort.asm       yours
search.asm     yours
util.asm       yours
run_tests.sh   provided: the correctness gate
tests/         provided: the test corpus
```

## What to Run

On Windows, run these commands in Git Bash, the shell from Block 1. In that
shell, `make` is your alias for `mingw32-make`. On Linux, use your terminal.

```bash
make
make check
```

`make` builds `bench`. `make check` builds, then runs `./run_tests.sh`,
which reports each check and exits nonzero when any of them fail. Each run
is captured first. Its exit status is read before its text is examined,
so a program that prints the right line and then crashes still fails.

## Reading a First Run

The assembly files ship as stubs that assemble and link as-is, so the build
works before you write any code. Right now they do nothing useful, and 19
of the 36 checks fail. The seventeen that pass prove little. Four are files
that arrive empty, single-element, or already sorted. `gcd(0, 0)` expects 0.
The hostile caller cannot be upset by a stub that touches no register. The
rest are argument and file refusals that the harness performs before any
assembly runs. That red run is the correct starting state for a starter. The
badge stays red until you implement the routines.

The provided files are fixtures. The grader compares your fork against the
starter. An edit to `bench.c`, `Makefile`, `run_tests.sh`, or a `tests/`
file appears as a diff in the open.

## Documentation

The three sections at the end of this file are yours. Complete Design Notes
and Subsystem Ownership before the Week 1 progress report. Complete Quirks
and Issues before the Week 3 progress report. Each section says what it
needs. Leave the rest of this file as it is.

---

## Design Notes

### Problem analysis

| Routines    | Purpose                                                                                                                                    |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `qsort_asm` | Expects a pointer to an array of 32-bit signed integers (`*arr`) and the array length (`n`); sorts array in place, so nothing is returned. |
| `bsearch_asm` | Expects a pointer to an array of 32-bit signed integers (`*arr`), the array length (`n`), and the value to find (`key`); returns index of `key` for a sorter array, and -1 otherwise. |
| `gcd_asm` | Expects two non-negative integers (`a` and `b`); returns greatest common divisor of `a` and `b`. | 
| `sum_range_asm` | Expects two integers that define the starting (`lo`) and ending (`hi`) points of an inclusive range; returns the sum of the range, assuming no overflow. |

Callee-saved registers will be preserved (`ebx`, `esi`, `edi`, `ebp`, `esp`). `ebp` is the stack frame anchor. Using them means restoring them before returning in the reverse order in which they were saved. Then return values go in `eax`. 

### Solution architecture
__The routine implementation of `qsort_asm` in `bench.c`:__ <br>
`void PRE_CDECL qsort_asm(int *arr, int n) POST_CDECL`
<br> <br>

__Contract in `bench.c` when fetching the arguments:__
| Argument | Address |
|---|---|
| int `n` | `[ebp+12]` |
| int `*arr` | `[ebp+8]` |
<br>

__Stack frame diagram of one recursive call of `qsort_asm`:__
| Address | Stack |
|---|---|
| `[ebp + 12]` | `n` (second args) |
| `[ebp + 8]` | `*arr` (first args) |
| `[ebp + 4]` | return address |
| `[ebp + 0]` | saved `ebp`, set `ebp = esp` |
| `[ebp - 4]` | `edi` (last pushed/saved register, first to pop/restore) |
| `[ebp - 8]` | `esi` (second pushed/saved register, second to pop/restore) |
| `[ebp - 12]` | `ebx` (first pushed/saved register, last to pop/restore) |

All saved local registers sit at negative offsets, below the `ebp`. Arguments start at `[ebp + 8]` to the increasing positive offsets of `ebp`.
<br>

__Why `sum_range_asm` is reentrant?__ <br>
`sum_range_asm` is reentrant because it calls `bench_callback` once per call and `bench.c` triggers another call of `sum_range_asm`, so the second call happens inside the first one before it even finishes, and reentrancy should allow it without corrupting the data of the first call due to overlapping calls that might break the execution. This is done by excluding the call of `bench_callback` from the recursive execution of `sum_range_asm`. The function must not contain static or global variables, `.data` or `.bss`, to avoid breaking reentrancy. It only uses `ebp` and `esp`, which live in the stack memory, and the local saved registers to avoid the overlapping calls write on the same variable.


### Measurements

The ratio `bench` reports on `random1000.txt`, `sorted1000.txt`,
`reverse1000.txt`, `duplicates.txt`, and `identical.txt`. Your worst case
and its cause. One improvement and its estimated effect.

| File | Ratio |
|---|---|
| `random1000.txt` | |
| `sorted1000.txt` | |
| `reverse1000.txt` | |
| `duplicates.txt` | |
| `identical.txt` | |


### Timeline

| Week | Goal                                                                                      | Owner              |
| ---- | ----------------------------------------------------------------------------------------- | ------------------ |
| 1    | Document problem analysis and solution architecture; build a working prototype.           | Cambel, Carreon    |
| 2    | Implement `qsort_asm`, `bsearch_asm`, and `gcd_asm`.                                      | De Guzman, Kaindoy |
| 3    | Implement `sum_range_asm`. Set up tests, documents issues and quirks, debugging (if any). | Cambel, Carreon    |
| 4    | Defense                                                                                   | All                |

## Subsystem Ownership

| Subsystem                                                    | Owner  |
| ------------------------------------------------------------ | ------ |
| Sorting (`qsort_asm` and its partition)                      |        |
| Searching (`bsearch_asm`, `gcd_asm`)                         | Kaindoy |
| Convention and measurement (`sum_range_asm`, the benchmarks) | Cambel, Carreon |

## Quirks and Issues

Complete this section before the Week 3 progress report. The syllabus asks
for documentation of quirks and issues with the complete implementation.
One entry per item. State what happens, what causes it, and what the group
did about it.

### Known issues

- 

### Quirks

- 
