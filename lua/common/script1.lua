local cookie = ""
local i, start, fin


function save_cookie(conn, payload)
    print(payload) 
    i, start = string.find(payload, 'session=')
    if start ~= nil then
        cookie = string.sub(payload, start + 1)
        i, fin = string.find(cookie, ';')
        cookie = string.sub(cookie, 1, fin - 1)
        print("Cookie: ", cookie)
    else
        print("Cookie not found")
    end

    local post = "POST /login HTTP/1.1\r\nHost: www.baidu.com\r\n"
        .."Connection: keep-alive\r\nAccept: */*\r\n"
        .."Set-Cookie:session="
        ..cookie
        .."\r\n"
        .."Content-Length:22\r\n\r\n"
        .."login=admin&pass=12345"

    print (post)

    conn:send(post)
    
end


function login ()
    conn=net.createConnection(net.TCP, 0)
    conn:on("receive", save_cookie )
    conn:on("connection", function(c)
        conn:send("GET / HTTP/1.1\r\nHost: www.baidu.com\r\n"
            .."Connection: keep-alive\r\nAccept: */*\r\n\r\n") 
        end)
    conn:connect(80,"192.168.14.19")
end


function pp (conn, payload)
    print(payload)
end


login()

local post = "POST /login HTTP/1.1\r\nHost: www.baidu.com\r\n"
.."Connection: keep-alive\r\nAccept: */*\r\n"
.."Set-Cookie:session="
..cookie
.."\r\n"
.."Content-Length:22\r\n\r\n"
.."login=admin&pass=12345"

print (post)
conn:send(post)





