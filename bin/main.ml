(* the objective of this project is to learn ocaml and build a web-server just for fun *)
let () = print_endline "Hello, World!"


let socket_domain : Unix.socket_domain = Unix.PF_INET
let socket_type : Unix.socket_type = Unix.SOCK_STREAM
let protocol : int = 0

let socket_handle : Unix.file_descr = Unix.socket socket_domain socket_type protocol
let ip :Unix.inet_addr = Unix.inet_addr_loopback
let addrress: Unix.sockaddr = Unix.ADDR_INET (ip, 3000)

let () = Unix.bind socket_handle addrress

(* now we will do a listen on this socket *)
let () = Unix.listen socket_handle 1024

let (new_socket_handle, client_address) = Unix.accept socket_handle
let crlf = "\r\n"
let protol_code = "HTTP/1.1"

let response (status_code: int) (reason: string) (headers: string list) =
    let status_line =
        protol_code ^ " " ^ string_of_int status_code ^ " " ^ reason
    in
    let lines = status_line :: headers in
    String.concat crlf lines ^ crlf ^ crlf

let response_text =
    response 200 "OK" ["Content-Length: 0"; "Connection: close"]
let total_bytes = String.length response_text
let bytes_written = Unix.write_substring new_socket_handle response_text 0 (String.length response_text)

let () = print_int bytes_written
let () =print_int total_bytes
