#!/usr/bin/env lua
io = require "io"

-- find the current spec
fd = io.popen("ls *.rockspec")
path = fd:read()
fd:close()

-- load it into global namespace
dofile(path)

for i=2,#dependencies do
  local dep = dependencies[i]
  
  print("installing " .. dep)
  local rc = os.execute("luarocks install " .. dep)
  if not rc then
    print("ERROR")
    os.exit(1)
  end
end
