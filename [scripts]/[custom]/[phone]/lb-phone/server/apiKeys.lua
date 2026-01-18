-- Webhook for instapic posts, recommended to be a public channel
INSTAPIC_WEBHOOK = "https://discord.com/api/webhooks/1403420246810820731/jk29JQo7OVb61bQNw2nQAElViOJvKVuJbMHdJbXnSs_naIh9mPxJK74F3p8_3QFPQJM6"
-- Webhook for Twitter posts, recommended to be a public channel
Twitter_WEBHOOK = "https://discord.com/api/webhooks/1403420025913741343/eHiPjjQIVWUajtFj7iGGfww3na5AGB1AmUKXRuvggHEB-FMuVGRaQ1SfPvuDA-jc5oAE"

-- Discord webhook or API key for server logs
-- We recommend https://fivemanage.com/ for logs. Use code "LBLOGS" for 20% off the Logs Pro plan
LOGS = {
    Default = "https://discord.com/api/webhooks/1403419829855322323/8mb44BetD_u98Ayg7YT5IbmVm-yNJCWl6qy2Sp0z4N--XYHZ9D-sV4MHrWlSRjVUjjUy", -- set to false to disable
    Calls = "https://discord.com/api/webhooks/1403420476755153020/lokVkOtZfaEyexPUSoUHmIcghleZ6O0QKU6slQoUlIHTGo8DJN_KNfK_zjj3qtNSagff",
    Messages = "https://discord.com/api/webhooks/1403420532514357340/G5puF_w1PuSr2WjPYQsh_yL6ey2cxqwvh68L5menp7C78xCoHLpasNfFW0GG71no9XhB",
    InstaPic = "https://discord.com/api/webhooks/1403419898973126766/mdMzbfCiOaparggAHM7hIHxNmcxXj-9lzOb7tY2Bn9ohu5maP5ryGhxozw-bIS9iWnU9",
    Twitter = "https://discord.com/api/s/1403420025913741343/eHiPjjQIVWUajtFj7iGGfww3na5AGB1AmUKXRuvggHEB-FMuVGRaQ1SfPvuDA-jc5oAE",
    YellowPages = "https://discord.com/api/webhooks/1403420592505622579/Uxd07JzP3WzNCViy8oy1tsFP0bHWMsfhkaWrf41VnjDGaU58Tz44wRoTTGUGrtRBrLhr",
    Marketplace = "https://discord.com/api/webhooks/1403420636684226692/1Oq27oRAt-Kmv095PiUJLXBhpmUSqTRgEo8K7Us-ioOr3G9kpMR0HNtv4Jl_0eBaJBCt",
    Mail = "https://discord.com/api/webhooks/1403420823380951170/vYAualN4XjdRT0KwxvNVy1l_ZproHfj4gF8gDaadSAEXrDCcEhnuxTS1qCWr1NwSa49T",
    Wallet = "https://discord.com/api/webhooks/1403420869438476369/UWCQ15gaT--zKg3-FwZJDy4ZrpFiRrmGIzF25vuwgubMtGKHiHenuPkFTTMWE2dovVov",
    DarkChat = "https://discord.com/api/webhooks/1403420911062745118/H-9oi0Bu4y1A-96piqQEHfekTERBztDcnGRxDgxQmNhA55jZJJu1Vmhz60humz-M0kIT",
    Services = "https://discord.com/api/webhooks/1403420953031217272/IBl1AJKBAlVqr1G2enPR054QjIsRRjgbGPZ69ZdlRksmgj4oxY8e9gm4ph6cgFu03RqV",
    Crypto = "https://discord.com/api/webhooks/1403421039916089478/eMJG4Ixh9bjVjioAG4gm9PvjS8wG_fLpjU7ZAy-PwuWAh1nRyHaj_bKSRqQ938iH4Pa9",
    Trendy = "https://discord.com/api/webhooks/1403421112423153828/GntwUmgnvzFVCLRWxm-nDxn3efHvX6OzIvJx9N4zGVFYMbG0K83Q2csXK_hl3_IGH6WY",
    Uploads = "https://discord.com/api/webhooks/1403421167494369330/qzcvBPgmyzrqxFlbcbCtCHImKQz25DZ22V5j5QVCL738tDIn7lJtmGOVdkIX8Jp7aFRc" -- all camera uploads will go here
}

DISCORD_TOKEN = nil -- you can set a discord bot token here to get the players discord avatar for logs

-- Set your API keys for uploading media here.
-- Please note that the API key needs to match the correct upload method defined in Config.UploadMethod.
-- The default upload method is Fivemanage
-- You can get your API keys from https://fivemanage.com/
-- Use code LBPHONE10 for 10% off on Fivemanage
-- A video tutorial for how to set up Fivemanage can be found here: https://www.youtube.com/watch?v=y3bCaHS6Moc
API_KEYS = {
    Video = "LKsLVfGhmWou9N0qh0kvCUFtLAnh7odi",
    Image = "LKsLVfGhmWou9N0qh0kvCUFtLAnh7odi",
    Audio = "LKsLVfGhmWou9N0qh0kvCUFtLAnh7odi",
}

-- Here you can set your credentials for Config.DynamicWebRTC
-- This is needed if video calls or InstaPic live streams are not working
-- You can get your credentials from https://dash.cloudflare.com/?to=/:account/realtime/turn/overview
WEBRTC = {
    TokenID = nil,
    APIToken = nil,
}