local love = require("love")

GameState = require("lib.hump.gamestate")

-- scenes
local Game = require("scenes.game")
local GameOver = require("scenes.game_over")
local DayEnd = require("scenes.day_end")

BACKGROUND_MUSIC = nil

function love.load()
	GameState.registerEvents()
	_handle_background_music()
	GameState.switch(Game, {
        show_play_screen = true
	})
end

function PlayBackgroundMusic()
    if not BACKGROUND_MUSIC then
        return
    end

    if not BACKGROUND_MUSIC:isPlaying() then
        BACKGROUND_MUSIC:play()
    end
end

function StopBackgroundMusic()
    if not BACKGROUND_MUSIC then
        return
    end

    if BACKGROUND_MUSIC:isPlaying() then
        BACKGROUND_MUSIC:stop()
    end
end

_G._handle_background_music = function ()
    BACKGROUND_MUSIC = love.audio.newSource("music/hotel_2.mp3", "stream")
    BACKGROUND_MUSIC:setVolume(0.2)
    BACKGROUND_MUSIC:setLooping(true)
    PlayBackgroundMusic()
end

function Tprint(tbl, indent)
	if not indent then indent = 0 end
	local toprint = string.rep(" ", indent) .. "{\r\n"
	indent = indent + 2 
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if (type(k) == "number") then
			toprint = toprint .. "[" .. k .. "] = "
		elseif (type(k) == "string") then
			toprint = toprint  .. k ..  "= "   
		end
		if (type(v) == "number") then
			toprint = toprint .. v .. ",\r\n"
		elseif (type(v) == "string") then
			toprint = toprint .. "\"" .. v .. "\",\r\n"
		elseif (type(v) == "table") then
			toprint = toprint .. Tprint(v, indent + 2) .. ",\r\n"
		else
			toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
		end
	end
	toprint = toprint .. string.rep(" ", indent-2) .. "}"
	return toprint
end

function TableLength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end