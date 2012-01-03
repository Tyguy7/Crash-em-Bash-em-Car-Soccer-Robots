local image_ext = {png=true, bmp=true}
local audio_ext = {ogg=true, mod=true, [".xm"]=true}

function art(filename)
	local extension = filename:sub(-3,-1)
	if image_ext[extension] then
		return love.graphics.newImage("res/images/"..filename)
	elseif audio_ext[extension] then
		if love.filesystem.isFile("res/music/"..filename) then
			return love.audio.newSource("res/music/"..filename)
		elseif love.filesystem.isFile("res/sounds/"..filename) then
			return love.audio.newSource("res/sounds/"..filename, "static")
		end
	end
end

