;; A simple web server written in assembly
format ELF64 executable

include 'macro.asm'
include 'def.asm'
include 'struct.asm'

segment readable executable
entry main
main:
    write STDOUT, start, start.size

    ;; Create socket fd
    write STDOUT, socket_msg, socket_msg.size
    socket AF_INET, SOCK_STREAM, 0
    handle_error 
    mov qword [socket_fd], rax

    ;; Set socket options
    mov dword [optval], 1
    setsockopt [socket_fd], IPPROTO_TCP, TCP_NODELAY, optval, 4

    ;; Bind socket
    write STDOUT, bind_msg, bind_msg.size
    mov word [servaddr.sin_family], AF_INET
    mov dword [servaddr.sin_addr], INADDR_ANY
    mov word [servaddr.sin_port], 14619 
    bind [socket_fd], servaddr.sin_family, sizeof_servaddr 
    handle_error 

    ;; Listen
    write STDOUT, listen_msg, listen_msg.size
    listen [socket_fd], 10
    handle_error

    ;; Accept Loop
next_request:
    write STDOUT, accept_msg, accept_msg.size
    accept [socket_fd], clientaddr.sin_family, sizeof_clientaddr
    handle_error 
    mov qword [conn_fd], rax

    write [conn_fd], response, response_len
    jmp next_request

    ;; Error handling
error:
    write STDERR, error_msg, error_msg.size
    close [conn_fd]
    close [socket_fd]
    exit 1

segment readable writeable



socket_fd dq -1
conn_fd dq -1
servaddr sockaddr_in
sizeof_servaddr = $ - servaddr.sin_family
clientaddr sockaddr_in
sizeof_clientaddr dd sizeof_servaddr 

ok db "OK", 10
start db "Starting web server...", 10
error_msg db "Error", 10
socket_msg db "Creating socket...", 10
bind_msg db "Binding socket...", 10
listen_msg db "Listening...", 10
accept_msg db "Waiting for client connections... ", 10
hello db "Hello from assembly", 10

response db "HTTP/1.1 200 OK", 13, 10
         db "Content-Type: text/html; charset=UTF-8", 13, 10
         db "Connection: close", 13, 10
         db 13, 10
         db "<html><head><title>Assembly</title></head><body><h1>Hello from assembly</h1></body></html>", 13, 10
response_len = $ - response

optval dd 1