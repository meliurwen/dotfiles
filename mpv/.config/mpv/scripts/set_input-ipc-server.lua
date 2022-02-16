
--[[--
  @script input-ipc-server-plus
  @author Meliurwen
  @license GPLv3
  This script makes possible the use of environment variables for the
  `input-ipc-server` property in the config file.

  The script triggers if and only if no `input-ipc-server` is set and the
  homonymous `input-ipc-server` option in `script-opts` is set in its place.

  A typical use case is to set the path with the env variable XDG_RUNTIME_DIR
  and a respective fallback path like this:

  @usage script-opts=input-ipc-server="${XDG_RUNTIME_DIR:-/tmp/$(id -u)-runtime}/mpv/main.sock"

  It's worth to note that it's possible to include subshells in order to compute
  part (or the whole) path. A typical use case, like in the just showed example
  is to stick to POSIX standards, using `$(id -u)` instead of `$USER`.
]]

local function isempty(s)
  return s == nil or s == ""
end

local function os_cmd_return(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  return string.format(result:match("^%s*(.+)"))
end

local ipc_opt_par = mp.get_property("input-ipc-server")
local ipc_opt_raw = mp.get_opt("input-ipc-server")
if isempty(ipc_opt_par) and not isempty(ipc_opt_raw) then
  local ipc_opt_fullpath = os_cmd_return('printf "%s" ' .. ipc_opt_raw)
  local ipc_opt_dirpath = os_cmd_return("dirname " .. ipc_opt_fullpath)
  os.execute("mkdir -p " .. ipc_opt_dirpath)
  mp.set_property("input-ipc-server", ipc_opt_fullpath)
end
