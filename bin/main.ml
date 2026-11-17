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

let response (status_code: int) (reason: string) (body : string) =
    let status_line =
        protol_code ^ " " ^ string_of_int status_code ^ " " ^ reason
    in
    let headers =
        [ "Content-Length: " ^ string_of_int (String.length body)
            ; "Connection: close" ] in
    let lines = status_line :: headers in
    String.concat crlf lines ^ crlf ^ crlf ^ body

let rec write_all (socket: Unix.file_descr) (content: string) (offset: int) =
    if offset = (String.length content) then ()
    else
    let bytes_written =
        Unix.write_substring socket content offset (String.length content - offset)
    in
    if bytes_written = 0 then failwith "retry"
    else write_all socket content (offset + bytes_written)

let parse_request (req_text: string) : string option =
    let lines = String.split_on_char '\r' req_text in
    let req_line: string option = match lines with
        | [] -> None
        | x :: rest -> Some x in

    match req_line with
    | None -> None
    | Some line ->
        match String.split_on_char ' ' line with
        | _ :: path :: version :: [] -> Some path
        | _ :: path :: [] -> Some path
        | _ ->None


let handle_client (new_socket_handle: Unix.file_descr) : unit =
    let buffer = Bytes.create 4096 in
    let n  = Unix.read new_socket_handle buffer 0 4096 in
    let req_text = Bytes.sub_string buffer 0 n in
    let path = parse_request req_text in
    let (code, reason , body) =
        match path with
            | Some "/" -> (200, "Ok", "hello!")
            | Some _ ->   (404, "Not Found", "not valid path")
            | None -> (400, "Bad Request", "not valid path")
    in
    let response_text = response code reason body in
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
