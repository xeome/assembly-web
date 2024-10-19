format ELF64 executable

include 'macro.asm'
include 'def.asm'
include 'struct.asm'
FILE_BUFFER_SIZE equ 4096
file_buffer rb FILE_BUFFER_SIZE

segment readable executable
entry main
main:
    write STDOUT, start_msg, start_msg.size

    ; Open `index.html`
    write STDOUT, file_open_msg, file_open_msg.size
    lea rdi, [index_html]
    mov rsi, O_RDONLY
    syscall2 SYS_open, rdi, rsi
    handle_error
    mov [file_fd], rax

    ; Read file contents into buffer
    write STDOUT, file_read_msg, file_read_msg.size
    mov rdi, [file_fd]
    lea rsi, [file_buffer]
    mov rdx, FILE_BUFFER_SIZE
    syscall3 SYS_read, rdi, rsi, rdx
    handle_error
    mov [file_size], rax

    ; Close the file descriptor
    close [file_fd]

    ; Create socket fd
    write STDOUT, socket_msg, socket_msg.size
    socket AF_INET, SOCK_STREAM, 0
    handle_error
    mov [socket_fd], rax

    ; Set socket options
    mov [optval], 1
    setsockopt [socket_fd], IPPROTO_TCP, TCP_NODELAY, optval, 4

    ; Bind socket
    write STDOUT, bind_msg, bind_msg.size
    mov word [servaddr.sin_family], AF_INET
    mov dword [servaddr.sin_addr], INADDR_ANY
    mov word [servaddr.sin_port], 14619
    bind [socket_fd], servaddr.sin_family, sizeof_servaddr
    handle_error

    ; Listen
    write STDOUT, listen_msg, listen_msg.size
    listen [socket_fd], MAX_CONNECTIONS
    handle_error

    ; Accept Loop
next_request:
    write STDOUT, accept_msg, accept_msg.size
    accept [socket_fd], clientaddr.sin_family, sizeof_clientaddr
    handle_error
    mov [conn_fd], rax

    ; Send HTTP response header
    write [conn_fd], response_header, response_header_len

    ; Send file contents
    mov rdi, [conn_fd]
    lea rsi, [file_buffer]
    mov rdx, [file_size]
    syscall3 SYS_write, rdi, rsi, rdx
    handle_error

    ; Close connection
    close [conn_fd]
    jmp next_request

    ; Error handling
error:
    write STDERR, error_msg, error_msg.size
    close [conn_fd]
    close [socket_fd]
    exit EXIT_FAILURE

segment readable writeable

socket_fd dq -1
conn_fd dq -1
file_fd dq -1
file_size dq 0
servaddr sockaddr_in
sizeof_servaddr = $ - servaddr.sin_family
clientaddr sockaddr_in
sizeof_clientaddr dd sizeof_servaddr

start_msg db "Starting web server...", 10
.start_msg.size = $ - start_msg

file_open_msg db "Opening index.html...", 10
.file_open_msg.size = $ - file_open_msg

file_read_msg db "Reading index.html...", 10
.file_read_msg.size = $ - file_read_msg

error_msg db "Error occurred!", 10
.error_msg.size = $ - error_msg

socket_msg db "Creating socket...", 10
.socket_msg.size = $ - socket_msg

bind_msg db "Binding socket...", 10
.bind_msg.size = $ - bind_msg

listen_msg db "Listening...", 10
.listen_msg.size = $ - listen_msg

accept_msg db "Waiting for client connections...", 10
.accept_msg.size = $ - accept_msg

response_header db "HTTP/1.1 200 OK", 13, 10
                db "Content-Type: text/html; charset=UTF-8", 13, 10
                db "Connection: close", 13, 10
                db 13, 10
response_header_len = $ - response_header

optval dd 1

index_html db 'index.html', 0