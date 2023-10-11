struc db [data]
{
    common
    . db data
    .size = $ - .
}

struc sockaddr_in
{
    .sin_family dw 0
    .sin_port dw   0
    .sin_addr dd   0
    .sin_zero dq   0
}