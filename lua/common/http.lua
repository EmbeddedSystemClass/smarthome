
local loggedin = 0
local i = 1
local relay_state = 0

cmds = {
    "relay R3 info\n",
    "relay R3 on\n",
    "relay R3 info\n",
    "relay R3 off\n"
}

function set_relay_cb(c, relay, state)
    if string.find(c, "Switch relay")~=nil then
        conn:send("relay " .. relay .. " info\n")
    end
    if string.find(c, "bt6500#")~=nil then
        conn:send("relay " .. relay .. " " .. state .. "\n")
    end
    if string.find(c, "service relay, Opened")~=nil then
        relay_state = 1
        print("Relay " .. " state: ", relay_state)
        print("Connection closed")
        conn:close()
    end
    if string.find(c, "service relay, Closed")~=nil then
        relay_state = 0
        print("Relay state: ", relay_state)
        print("Connection closed")
        conn:close()
    end
end

function login_cb(c)
    if string.find(c, "bt6500 login:")~=nil then
            conn:send("admin\n")
    end 
    if string.find(c, "Password:")~=nil then
        conn:send("12345\n")
    end    
    if string.find(c, "bt6500#")~=nil then
        print("Logged in")
        loggedin=1
    end
end

function commands_cb(c)
    if cmds[i]==nil then   
        conn:close()
        print("Connection closed")
    end
    if string.find(c, "bt6500#")~=nil then
        conn:send(cmds[i])
        i=i+1
    end 

end

function connect()
    print("Connecting..")
    conn=net.createConnection(net.TCP, 0)
    
    conn:on("receive", function(conn, c) 
        print(c)
        
        if loggedin==0 then
            login_cb(c)
        end

        --commands_cb(c);
        
        set_relay_cb(c, "R3", "off")
        
    end )
    
    conn:connect(23,"192.168.14.19")

end

connect()
