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
ya = { sync = function(fn) return fn end }
local convert = dofile(arg[2] or root .. "/main.lua").convert

local checks = 0
local function expect(mode, name, is_dir, expected)
	checks = checks + 1
	local actual = convert(name, is_dir, mode)
	assert(
		actual == expected,
		string.format("%s %q: expected %q, got %q", mode, name, expected, tostring(actual))
	)
end

expect("kebab", "My File_name.TXT", false, "my-file-name.TXT")
expect("snake", "myFileName.md", false, "my_file_name.md")
expect("caps", "my-file name.md", false, "MY_FILE_NAME.md")
expect("pascal", "my_file-name.md", false, "MyFileName.md")
expect("camel", "My File Name.md", false, "myFileName.md")
expect("snake", "HTTPServer.go", false, "http_server.go")
expect("kebab", "Version2 Final.txt", false, "version2-final.txt")
expect("kebab", "My Photos.2024", true, "my-photos-2024")
expect("snake", ".Hidden Config", false, ".hidden_config")
expect("kebab", "Old Backup.tar.gz", false, "old-backup.tar.gz")
expect("kebab", "...Hidden File.TXT", false, "...hidden-file.TXT")
expect("caps", "мой файл.txt", false, "МОЙ_ФАЙЛ.txt")
expect("pascal", "мой ёжик.txt", false, "МойЁжик.txt")
expect("icao", "Щука и ёж.txt", false, "Shchuka i ezh.txt")
expect("icao", "Юля-2 ПЬЕСА.md", false, "Iulia-2 PESA.md")
expect("icao", "Хорошо mix.txt", false, "Khorosho mix.txt")
expect("icao", "Ъезд мягкий Ь.txt", false, "Ieezd miagkii .txt")
expect("icao", "中文 한국어.txt", false, "中文 한국어.txt")
expect("kebab", "École Française.txt", false, "école-française.txt")
expect("caps", "άλφα βήτα.txt", false, "ΆΛΦΑ_ΒΉΤΑ.txt")
expect("snake", "ПривітСвіт.txt", false, "привіт_світ.txt")
expect("camel", "ČESKÝ NÁZEV.md", false, "českýNázev.md")
expect("kebab", "ǅuro Test.txt", false, "ǆuro-test.txt")
expect("caps", "straße.txt", false, "STRAßE.txt")
expect("kebab", "Untouched 中文 🐈.txt", false, "untouched-中文-🐈.txt")
expect("kebab", "𐐀𐐨.txt", false, "𐐨𐐨.txt")
expect("unknown", "some.txt", false, nil)

print(string.format("rename-case: %d name conversions passed", checks))
