macro syscall1 name, arg1
{
    mov rax, name
    mov rdi, arg1
    syscall
}

macro syscall2 name, arg1, arg2
{
    mov rax, name
    mov rdi, arg1
    mov rsi, arg2
    syscall
}

macro syscall3 name, arg1, arg2, arg3
{
    mov rax, name
    mov rdi, arg1
    mov rsi, arg2
    mov rdx, arg3
    syscall
}

macro syscall5 name, arg1, arg2, arg3, arg4, arg5
{
    mov rax, name
    mov rdi, arg1
    mov rsi, arg2
    mov rdx, arg3
    mov r10, arg4
    mov r8, arg5
    syscall
}

macro write output,string, len
{
    syscall3 SYS_write, output, string, len
}

macro exit status
{
    syscall1 SYS_exit, status 
}

macro close fd
{
    syscall1 SYS_close, fd
}

macro socket domain, type, protocol
{
    syscall3 SYS_socket, domain, type, protocol
}

macro bind sockfd, addr, addrlen
{
    syscall3 SYS_bind, sockfd, addr, addrlen
}

macro listen sockfd, backlog
{
    syscall2 SYS_listen, sockfd, backlog
}

macro accept sockfd, addr, addrlen
{
    syscall3 SYS_accept, sockfd, addr, addrlen
}

macro setsockopt sockfd, level, optname, optval, optlen
{
    syscall5 SYS_setsockopt, sockfd, level, optname, optval, optlen
}