local w, h = term.getSize()
local users
local function clear()
  term.setBackgroundColor(colors.white)
  term.clear()
  term.setCursorPos(1,1)
  term.setTextColor(colors.black)
end
local function header(aR, xChar)
  if not xChar then
    local xChar = "X"
  end
  local w, h = term.getSize()
  paintutils.drawLine(1,1,w,1,colors.brown)
  term.setTextColor(colors.white)
  if aR then
    term.setCursorPos(2,1)
    write("Add")
    term.setCursorPos(7,1)
    write("Remove")
  end
  term.setCursorPos(w,1)
  write(xChar)
end

users = {}
if fs.exists("/.sPhone/config/buddies") then
  local f = fs.open("/.sPhone/config/buddies", "r")
  repeat
    local line = f.readLine()
    table.insert(users, line)
  until not line
  f.close()
end

local function add()
  clear()
  header(false, "<")
  term.setBackgroundColor(colors.white)
  term.setTextColor(colors.black)
  term.setCursorPos(2,3)
  sertextext.center(3, "  Name")
  term.setCursorPos(2,5)
  term.setCursorBlink(true)
  local e,_,x,y = os.pullEvent()
  if e == "mouse_click" then
    if y == 1 and x == w then
      return
    end
  elseif e == "char" then
    local add = read()
  end
  term.setCursorBlink(false)
  --local check = http.post("http://sertex.esy.es/check.php","user="..add).readLine()
  
  --if check == "true" then
    table.insert(users,add)
    local f = fs.open("/.sPhone/config/buddies", "a")
    f.write(add.."\n")
    f.close()
    sPhone.winOk("Added!")
  --else
    --sPhone.winOk("User does", "not exist!")
  --end
end

local function remove()
  while true do
    clear()
    header(false, "<")
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(1,2)
    for i = 1, #users do
      print(users[i])
    end
    local _,_,x,y = os.pullEvent("mouse_click")
    if y == 1 and x == w then
      return
    elseif y ~= 1 then
      if users[y-1] then
        if sPhone.yesNo("Remove "..users[y-1].."?",nil,false) then
          table.remove(users, users[y-1])
          local f = fs.open("/.sPhone/config/buddies", "w")
          for i = 1, #users do
            f.write(users[i].."\n")
          end
          f.close()
        end
      end
    end
  end
end

while true do
  local function redraw()
    clear()
    header(true, "X")
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    for i = 1, #users do
      print(users[i])
    end
  end
  redraw()
  local _,_,x,y = os.pullEvent("mouse_click")
  if y == 1 then
    if x >= 2 and x <= 4 then
      add()
    elseif x >= 7 and x <= 12 then
      remove()
    elseif x == w then
      return
    end
  else
    if users[y-1] then
      shell.run("/.sPhone/apps/sms", users[y-1])
    end
  end
end