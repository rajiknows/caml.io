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

let protol_code = "HTTP/1.1"
let crlf = "\r\n"

let response (status_code: int) (reason: string) (headers: string list) =
    let status_line =
        protol_code ^ " " ^ string_of_int status_code ^ " " ^ reason
    in
    let lines = status_line :: headers in
    String.concat crlf lines ^ crlf ^ crlf

let rec write_all (socket: Unix.file_descr) (content: string) (offset: int) =
    if offset = (String.length content) then ()
    else
    let bytes_written =
        Unix.write_substring socket content offset (String.length content - offset)
    in
    if bytes_written = 0 then failwith "retry"
    else write_all socket content (offset + bytes_written)

let parse_request (req_text: string) : string =
    let lines = String.split_on_char '\r' req_text in
    let req_line = match lines with
        | [] -> "nothing"
        | x :: rest -> x in

    let parts =  match String.split_on_char ' ' req_line with
        | [] -> "error"
        | _ :: path :: version :: [] -> path
        | _ :: path :: [] -> path
        | _ -> "fallback" in

    let () = print_string parts in
     parts



let handle_client (new_socket_handle: Unix.file_descr) : unit =
    let buffer = Bytes.create 4096 in
    let n  = Unix.read new_socket_handle buffer 0 4096 in
    let req_text = Bytes.sub_string buffer 0 n in
    let _path =  parse_request req_text in



    let response_text =
        response 200 "OK" ["Content-Length: 0"; "Connection: close"]
    in
    write_all new_socket_handle response_text 0;
    Unix.close new_socket_handle

let () =
        Sys.set_signal Sys.sigchld Sys.Signal_ignore;
while true do
    let (new_socket_handle, _client_address) = Unix.accept socket_handle in
    let pid = Unix.fork () in
    if pid = 0 then begin(*this is child process*)
        Unix.close socket_handle;
        handle_client new_socket_handle;
        exit 0
        end
    else
        Unix.close new_socket_handle
done
