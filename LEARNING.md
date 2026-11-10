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

## Current state

The server in `bin/main.ml` currently:

- Creates an IPv4 TCP socket, binds to `0.0.0.0:3000`, listens (backlog 1024).
- Loops forever: accepts a client, builds a fixed `HTTP/1.1 200 OK` response,
  writes it fully, closes the client socket.
- Ignores the request entirely — no reading or parsing yet.
- Handles one client at a time (a client that connects and sends nothing
  blocks everyone).

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

## Known bug

`write_all` still requests `String.length content` instead of
`String.length content - offset`. Harmless at offset 0 with a tiny response,
but must be fixed.

## Next milestones (in order)

1. **Read the request** — `Unix.read` into a `Bytes` buffer; learn `Bytes` vs
   `string`, buffers, partial reads.
2. **Parse the request line** — split on `\r\n`, then on spaces; learn
   `String.split_on_char` / `String.index` / pattern matching on lists.
3. **Routing with `match`** — respond `200` for known paths, `404` otherwise.
   This is where pattern matching gets interesting (like Rust's `match`).
4. **Response with a body** — add `Content-Length` computed from the body.
5. **Later:** concurrency (fork/thread per client), header parsing, request
   bodies, error handling with exceptions.
