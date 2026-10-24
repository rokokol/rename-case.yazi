std = "lua54"
max_line_length = 100
globals = { "ya" }
read_globals = { "cx", "fs", "Url" }

files["tests/entry.lua"] = {
  globals = { "ya", "cx", "fs", "Url" },
}
