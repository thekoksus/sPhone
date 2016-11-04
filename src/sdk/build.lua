local args = {...}
if not sPhone then
	print("build requires sPhone")
end
if #args < 2 then
	print("Usage: build <App Folder> <Output>")
	return
end

local dir = args[1]
local output = args[2]
local final = {}
local builderVersion = 1

if not fs.exists(dir) or not fs.isDir(dir) then
	print("Input must be a folder")
	return
end


local f = fs.open(dir.."/config","r")
local _config = textutils.unserialize(f.readAll())
f.close()
if not _config then
	print("Config file is corrupted")
	return
end

-- COMPRESS

local filesystem = {}
 
local function readFile(path)
        local file = fs.open(path,"r")
        local variable = file.readAll()
        file.close()
        return variable
end
 
local function explore(dir)
        local buffer = {}
        local sBuffer = fs.list(dir)
        for i,v in pairs(sBuffer) do
                sleep(0.05)
                        if fs.isDir(dir.."/"..v) then
                                if v ~= ".git" then
                                        buffer[v] = explore(dir.."/"..v)
                                end
                        else
                                buffer[v] = readFile(dir.."/"..v)
                        end
        end
        return buffer
end


-- COMPRESS

local result = {}


print("Name:",_config.name)
print("Author:",_config.author)
print("Version:",_config.version)
print("ID:",_config.id)

if string.getExtension(output) ~= "spk" then
	printError("TIP: Use .spk extension")
end

print("Building...")

local filesystem = explore(args[1].."/main")
result["files"] = textutils.serialize(filesystem)
result["config"] = textutils.serialize(_config)


local newResult = textutils.serialize(result)
local info = "--\n-- sPhone Application Package\n-- Built with SPK builder "..builderVersion.."\n--"
local f = fs.open(output,"w")
f.write(info.."\n"..newResult)
f.close()
