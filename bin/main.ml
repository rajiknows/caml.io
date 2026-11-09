(* the objective of this project is to learn ocaml and build a web-server just for fun *)
let () = print_endline "Hello, World!"


let socket_domain : Unix.socket_domain = Unix.PF_INET
let socket_type : Unix.socket_type = Unix.SOCK_STREAM
let protocol : int = 0

let socket_handle : Unix.file_descr = Unix.socket socket_domain socket_type protocol
let ip :Unix.inet_addr = Unix.inet_addr_loopback
let addrress: Unix.sockaddr = Unix.ADDR_INET (ip, 3000)

let () = Unix.bind socket_handle addrress
