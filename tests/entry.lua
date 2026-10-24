local root = arg[1] or "."
-- Yazi hands plugin modules out as a proxy that reads only string keys
local function yazi_module(load)
	return setmetatable({ __mod = load() }, {
		__index = function(self, key)
			if type(key) == "string" then return self.__mod[key] end
		end,
	})
end
package.preload["rename-case.case"] = function()
	return yazi_module(function() return dofile(root .. "/case.lua") end)
end
package.preload["rename-case.translit"] = function()
	return yazi_module(function() return dofile(root .. "/translit.lua") end)
end

local files, moves, notices, revealed, rename_error
ya = {
	sync = function(fn) return fn end,
	notify = function(value) notices[#notices + 1] = value end,
	emit = function(name, args)
		assert(name == "reveal")
		revealed = tostring(args[1])
	end,
}
cx = { active = { selected = {}, current = {} } }

Url = function(path)
	return setmetatable({ path = path }, {
		__tostring = function(value) return value.path end,
		__index = function(value, key)
			if key == "name" then
				return value.path:match "[^/]+$"
			elseif key == "parent" then
				return Url(value.path:match "^(.*)/[^/]+$")
			elseif key == "join" then
				return function(parent, name) return Url(parent.path .. "/" .. name) end
			end
		end,
	})
end
fs = {
	cha = function(path) return files[tostring(path)] and {} end,
	rename = function(from, to)
		if rename_error then return false, rename_error end
		from, to = tostring(from), tostring(to)
		assert(files[from], "the source must exist")
		assert(not files[to], "an existing target must never reach rename")
		files[to], files[from] = files[from], nil
		moves[#moves + 1] = { from, to }
		return true
	end,
}

local plugin = dofile(root .. "/main.lua")

local function reset(paths, selected, hovered)
	files, moves, notices, revealed, rename_error = paths, {}, {}, nil, nil
	cx.active.selected = selected or {}
	cx.active.current.hovered = hovered
end

local function file(path, is_dir) return { url = path, cha = { is_dir = is_dir or false } } end

reset({ ["/work/My File.TXT"] = "contents" }, nil, file "/work/My File.TXT")
plugin:entry { args = { "kebab" } }
assert(files["/work/my-file.TXT"] == "contents", "the hovered file must retain its contents")
assert(not files["/work/My File.TXT"], "the source must disappear after a rename")
assert(revealed == "/work/my-file.TXT", "the cursor must follow the renamed file")

reset({
	["/work/First File.txt"] = "one",
	["/work/My Photos.2024"] = "directory",
	["/work/Untouched"] = "other",
}, { file "/work/First File.txt", file("/work/My Photos.2024", true) }, file "/work/Untouched")
plugin:entry { args = { "snake" } }
assert(files["/work/first_file.txt"] == "one")
assert(files["/work/my_photos_2024"] == "directory", "directories must not keep a false extension")
assert(files["/work/Untouched"] == "other", "a selection must take priority over the hovered file")
assert(#moves == 2)

reset(
	{ ["/work/My File.txt"] = "source", ["/work/my-file.txt"] = "target" },
	nil,
	file "/work/My File.txt"
)
plugin:entry { args = { "kebab" } }
assert(files["/work/My File.txt"] == "source" and files["/work/my-file.txt"] == "target")
assert(#moves == 0, "a collision must not overwrite either file")
assert(#notices == 1 and notices[1].content:find("my-file.txt", 1, true))

reset({ ["/work/already-done.txt"] = "same" }, nil, file "/work/already-done.txt")
plugin:entry { args = { "kebab" } }
assert(#moves == 0 and #notices == 0)
assert(revealed == "/work/already-done.txt")

reset({ ["/work/My File.txt"] = "source" }, nil, file "/work/My File.txt")
rename_error = "access refused"
plugin:entry { args = { "kebab" } }
assert(files["/work/My File.txt"] == "source" and #moves == 0)
assert(#notices == 1 and notices[1].level == "error")
assert(notices[1].content:find(rename_error, 1, true))
assert(revealed == nil, "a failed rename must not move the cursor")

reset({ ["/work/file.txt"] = "source" }, nil, file "/work/file.txt")
plugin:entry { args = { "unknown" } }
assert(#moves == 0 and notices[1].level == "error")

reset {}
plugin:entry { args = { "kebab" } }
assert(#moves == 0 and #notices == 0)
print "rename-case: selection, collisions, errors and cursor behavior passed"
