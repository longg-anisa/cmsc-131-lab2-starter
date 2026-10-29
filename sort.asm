;
; sort.asm - qsort_asm, a recursive quicksort callable from C.
;
; This is your starting point: it assembles and links as-is, so the build
; works before you write any code. Right now it does nothing, which makes
; the benchmark print "NOT SORTED" and "Match: NO". Your job is to replace
; that with the sort described below.
;
; The contract, from bench.c:
;
;       int n                     [ebp+12]
;       int *arr                  [ebp+8]
;
; Sort n 32-bit signed integers in place, ascending. This is the C-facing
; routine. It must obey cdecl (prologue, args at [ebp+8]+, return in eax,
; preserve ebx/esi/edi/ebp, clean arguments after every call it makes). The
; manual lets you use any convention you document for the internal recursive
; routine, but the outer one is fixed.
;
; Requirements from the manual:
;
;   * Recursive. An iterative sort with an explicit stack array does not
;     satisfy the activity.
;   * Lomuto partition with the last element as pivot (the manual's scheme).
;   * No calls into the C standard library.
;   * Clean the arguments off the stack after each call. The next pop
;     otherwise loads an argument into a register you promised to
;     preserve, and the outer call's array base is gone.
;
; The manual's pseudocode:
;
;   qsort(arr, lo, hi):
;       if lo >= hi: return
;       p = partition(arr, lo, hi)
;       qsort(arr, lo, p - 1)
;       qsort(arr, p + 1, hi)
;
;   partition(arr, lo, hi):
;       pivot = arr[hi]
;       i = lo - 1
;       for j = lo to hi - 1:
;           if arr[j] <= pivot:
;               i = i + 1
;               swap arr[i], arr[j]
;       swap arr[i + 1], arr[hi]
;       return i + 1
;

; Windows C puts a leading underscore on every exported name. Linux C does
; not. The Makefile passes -d ELF_TYPE on Linux. This block then respells
; the names below to match. asm_io.inc does the same for _asm_main in the
; bootcamp blocks. Leave this block alone.
%ifdef ELF_TYPE
  %define _qsort_asm qsort_asm
  section .note.GNU-stack noalloc noexec nowrite progbits
%endif

segment .text
        global  _qsort_asm
_qsort_asm:
        enter   0,0
        pusha

        mov     eax, [ebp+12]   ; eax = n
        cmp     eax, 2
        jl      .done           ; n < 2: skip sort

        dec     eax
        push    eax             ; hi
        push    dword 0         ; lo
        push    dword [ebp+8]   ; arr
        call    qsort_inner
        add     esp, 12

.done:
        popa
        mov     eax,0
        leave
        ret


; qsort_inner(int *arr, int lo, int hi)
qsort_inner:
        push    ebp
        mov     ebp, esp
        sub     esp, 4

        ;base case
        mov     eax, [ebp+12]
        cmp     eax, [ebp+16]
        jge     .done

        ; p = partition(arr, lo, hi)
        push    dword [ebp+16]      ; hi
        push    dword [ebp+12]      ; lo
        push    dword [ebp+8]       ; arr
        call    partition
        add     esp, 12
        mov     [ebp-4], eax

        ; qsort_inner(arr, lo, p - 1)
        dec     eax                 ; eax = p - 1
        push    eax                 ; hi
        push    dword [ebp+12]      ; lo
        push    dword [ebp+8]       ; arr
        call    qsort_inner
        add     esp, 12

        ; qsort_inner(arr, p + 1, hi)
        mov     eax, [ebp-4]        ; reload p
        inc     eax                 ; eax = p + 1
        push    dword [ebp+16]
        push    eax
        push    dword [ebp+8]
        call    qsort_inner
        add     esp, 12

        
.done:
        mov     esp, ebp
        pop     ebp
        ret

;partition(arr, lo, hi)
partition:
        push    ebp
        mov     ebp, esp

        mov     esi, [ebp+8]        ; arr
        mov     eax, [ebp+16]       ; hi
        mov     edi, [esi+eax*4]    ; pivot = arr[hi] LOV U MAM ARA
        mov     ebx, [ebp+12]       ; lo
        dec     ebx                 ; i = lo-1

        mov     edx, [ebp+12]       ; j start val

.loop:
        cmp     edx, [ebp+16]
        jge     .after

        ;if arr[j] <= pivot
        mov     eax, [esi + edx*4]  ; load arr[j]
        cmp     eax, edi            ; add[j] > pivot?
        jg      .skip
        inc     ebx                 ; i++
        
        ;swap
        mov     eax, [esi + ebx*4]  ; arr[i]
        mov     ecx, [esi + edx*4]  ; arr[j]
        mov     [esi + ebx*4], ecx
        mov     [esi + edx*4], eax
.skip:
        inc     edx
        jmp     .loop
.after:
        inc     ebx

        ;final swap
        mov     eax, [esi + ebx*4]
        mov     ecx, [esi + edx*4]
        mov     [esi + ebx*4], ecx
        mov     [esi + edx*4], eax

        mov     eax, ebx            ; return p = i + 1
        mov     esp, ebp
        pop     ebp
        ret


