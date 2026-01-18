config = {}

-- How much ofter the player position is updated ?
config.RefreshTime = 300

-- default sound format for interact
config.interact_sound_file = "ogg"

-- is emulator enabled ?
config.interact_sound_enable = true

-- how much close player has to be to the sound before starting updating position ?
config.distanceBeforeUpdatingPos = 40

-- Message list
config.Messages = {
    ["streamer_on"]  = "Odpaliłes streamermode, od teraz nie słyszysz CarRadia oraz Dyskoteki.",
    ["streamer_off"] = "Wylaczyłes streamermode, od teraz słyszysz CarRadia oraz Dyskoteki.",

    ["no_permission"] = "Nie posiadasz permisji do uzycia tej komendy!",
}
-- Addon list
-- True/False enabled/disabled
config.AddonList = {
    crewPhone = false,
}