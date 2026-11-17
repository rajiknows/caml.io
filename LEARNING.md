# Learning OCaml by Building an HTTP Server

A handover document for continuing this learning session in a new conversation
or on a different machine.

## Teaching arrangement

- **The learner writes all code.** The teacher explains concepts, gives small
  exercises, reviews attempts, and does not provide solution code up front.
  Hints come first; full answers only when asked.
- The learner knows **Rust** — explain OCaml by analogy where useful
  (variants ≈ enums, `match` ≈ `match`, `unit` ≈ `()`).
- Milestone-driven: each step introduces only the OCaml concepts needed.
- **Installed OCaml: 5.4.1.** Always verify APIs against this version before
  teaching them — e.g. `Sys.set_signal` exists, `Unix.set_signal` does not.
  Check with a small compile test when unsure.

## Current state

The server in `bin/main.ml` currently:

- Creates an IPv4 TCP socket, binds to `127.0.0.1:3000`, listens (backlog 1024).
- Accept loop `fork`s a child per connection — concurrent clients work.
- `Sys.set_signal Sys.sigchld Sys.Signal_ignore` reaps children (OCaml 5:
  it's in `Sys`, not `Unix`).
- Children read up to 4096 bytes with `Unix.read` into a `Bytes` buffer.
- `parse_request` extracts the path and returns `string option`
  (`Some path` / `None`).
- `handle_client` matches the path: `/` → 200 `hello!`, other paths → 404,
  malformed → 400. Builds response via a `(code, reason, body)` tuple.

## Concepts already taught

| Concept | Notes |
|---|---|
| `unit` / `()` | Type of effect-producing expressions; `let () = …` at top level |
| `let` bindings | Immutable by default; `let name : type = value` annotations |
| Function calls | Space-separated args; `f x y`, not `f(x, y)`. Commas build tuples |
| Type annotations | `(param : type)` for params, `let f … : ret =` for return type |
| `let … in` | Local bindings inside a function; `in` is not a statement terminator |
| Variants | `Unix.ADDR_INET (ip, port)` — constructors carry values, like Rust enums |
| Lists | `string list`, `["a"; "b"]` (semicolons!), `::` prepend |
| `String.concat` | `separator -> string list -> string`, used to join headers |
| `string` vs `bytes` | Immutable vs mutable byte sequences |
| `let rec` | Required for self-calls; tail recursion as the iteration style |
| `;` sequencing | `expr1; expr2` — run both, keep second result |
| `while … do … done` | Infinite accept loop |

## Network functions used

- `Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0` — create TCP socket
- `Unix.inet_addr_loopback` / `Unix.inet_addr_any` — `127.0.0.1` / `0.0.0.0`
- `Unix.bind`, `Unix.listen`, `Unix.accept` — returns `(client_fd * sockaddr)` pair
- `Unix.write_substring fd str off len` — may write fewer bytes than asked;
  `write_all` recursion handles partial writes
- `Unix.close` — sockets need explicit cleanup (no `Drop`)

## Concepts added since this doc was written

- `match` on list patterns (`x :: rest`, literals, `_` wildcard)
- `string option` — `Some` / `None`, nested matches unwrap it
- `Unix.fork ()` — returns `0` in child, child pid in parent; child must
  `exit 0`, parent closes the accepted socket
- `Unix.read fd bytes off len`, `Bytes.create`, `Bytes.sub_string`
- `if … then begin …; … end else …` — multi-statement branches need begin/end
- `Sys.set_signal Sys.sigchld Sys.Signal_ignore` — zombie reaping

## Next milestones (in order)

1. **Method-aware routing** (in progress) — `parse_request` should return
   `(method * path)` so the router can distinguish `GET /` from `POST /`.
2. **Dynamic paths** — `/hello/<name>`; split path on `/`, match segments.
3. **Later:** header parsing, request bodies, exceptions for cleanup
   (`try … with` / `Fun.protect`), replacing `fork` with `Domain` threads.
