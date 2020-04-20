sounds = {
    radio_static = love.audio.newSource("audio/radio_static.wav", "static"),
    radio_beep = love.audio.newSource("audio/radio_beep.wav", "static"),
    gunshot = love.audio.newSource("audio/gunshot.wav", "static"),
    stab = love.audio.newSource("audio/stab.wav", "static"),
    stab_attempt = love.audio.newSource("audio/stab_attempt.wav", "static")
}

music = {
    track1 = love.audio.newSource("audio/track1.wav", "static")
}

music.track1:setLooping(true)
