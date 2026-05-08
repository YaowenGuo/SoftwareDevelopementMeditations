This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **documentation-only repository** — a collection of Chinese/English technical notes on concurrency in computer systems. There are no build steps, tests, or executable code. All content is in Markdown (`.md`) format.

## Structure

The repository is organized by concurrency mechanism:

- `README.md` — Top-level introduction: defines concurrency, parallelism, and motivations for concurrent programming
- `SUMMARY.md` — Comparative summary of processes vs. threads (Linux `task_struct`, scheduling, efficiency)
- `process/` — Process concepts, POSIX API (`fork`, `exec`, `waitpid`), signals, IPC, Binder, scheduling
  - `IPC.md`, `binder.md`, `signal.md`, `scheduling.md`
  - `ipc/shared_memary.md`
- `thread/` — Thread models (1:1, 1:N, M:N), POSIX Pthreads API, synchronization, locking concepts, C++11 memory model, atomic operations, TLS, NPTL
  - `README.md` — Core thread doc (thread API, lock types, memory model)
  - `atomic_c11.md`, `bionic_lock.md`, `c++_object_model.md`, `java_and_android.md`, `nptl.md`, `tls.md`
- `coroutine/` — Coroutine concepts; Kotlin coroutine features
  - `README.md`, `kotlin/feature.md`
- `io_multiplexing/` — I/O multiplexing (select, poll, epoll) and benchmarks
- `scheduler/` — Linux scheduler internals
  - `linux_scheduler.md`, `README.md`
- `concurrence_safe/` — Concurrency safety patterns
- `images/` — Diagrams referenced by the markdown files

## Content Language

Documents are written in a mix of Chinese and English. Core concepts are often introduced in English (quoting textbooks such as CSAPP and OSTEP) and elaborated in Chinese.
