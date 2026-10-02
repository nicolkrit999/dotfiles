local dashboard = require("dashboard")
local ascii = require("ascii")

local conf = {}

-- conf.header = {
--   "                                                       ",
--   "                                                       ",
--   "                                                       ",
--   " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
--   " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
--   " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
--   " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
--   " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
--   " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
--   "                                                       ",
--   "                                                       ",
--   "                                                       ",
--   "                                                       ",
-- }


-- conf.header = {
	-- "                                                       ",
  -- "                                                       ",
  -- "               ,'``.._   ,'``.                         ",
	-- "              :,--._:)\\,:,._,.:       All Glory to     ",
	-- "              :`--,''   :`...';\\      the HYPNO TOAD!  ",
	-- "               `,'       `---'  `.                     ",
	-- "               /                 :                     ",
	-- "              /                   \\                    ",
	-- "            ,'                     :\\.___,-.           ",
	-- "           `...,---'``````-..._    |:       \\          ",
	-- "             (                 )   ;:    )   \\  _,-.   ",
	-- "              `.              (   //          `'    \\  ",
	-- "               :               `.//  )      )     , ;  ",
	-- "             ,-|`.            _,'/       )    ) ,' ,'  ",
	-- "            (  :`.`-..____..=:.-':     .     _,' ,'    ",
	-- "             `,'\\ ``--....-)='    `._,  \\  ,') _ '``._ ",
	-- "          _.-/ _ `.       (_)      /     )' ; / \\ \\`-.'",
	-- "         `--(   `-:`.     `' ___..'  _,-'   |/   `.)   ",
	-- "             `-. `.`.``-----``--,  .'                  ",
	-- "               |/`.\\`'        ,','); Natale           ",
	-- "                   `         (/  (/                    ",
-- }

-- conf.header = {
--  "                                            ",
--  "                                            ",
--  "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣿⣦⣀⠀⠀⠀⠀⠀⣀⣤⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣨⣿⣿⠿⠻⣿⡀⠀⠀⠀⣨⣿⣿⠿⠻⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⠋⠀⢠⣿⣧⠀⠀⣴⣿⣿⣿⡟⠉⢿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⡟⠀⣤⠉⣿⣿⠀⢠⣿⣿⣿⡟⠀⠀⢸⣿⣟⠂⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣺⣿⣿⠀⣰⣿⠀⣿⣿⠀⣾⣿⣿⡟⠀⣠⡄⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⠃⠀⣿⡏⢠⣿⣿⣤⣿⣿⣿⠁⢸⣿⡇⢸⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣀⣼⣿⣷⣿⡿⣿⠿⠿⣿⣧⣠⣿⣿⢁⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⡿⣽⣿⣷⣶⡋⠂⠀⣊⠀⢉⠽⠻⢿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⢠⣞⣹⡿⣿⣿⣿⣿⣻⣿⣷⣧⣰⡀⠉⠀⢀⡠⠎⠩⣭⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⢠⠄⣰⠟⣻⣿⡿⢿⣿⣿⣿⣿⣷⣿⣿⣿⡇⠀⡙⣻⣦⠀⢸⣖⠒⠺⣷⡀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠠⠃⢸⣷⡿⠋⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣾⣿⡿⣿⣷⣏⠉⢛⣀⣼⡇⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⢠⣶⡟⢉⣴⣿⣿⣿⣿⣿⣿⣿⡿⠛⠛⠋⠉⠛⠻⢿⣿⣿⣽⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⢰⡿⢟⣿⣿⣿⣿⣿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠙⠻⣿⣿⣽⣿⣷⠀⠀⠀⠀",
--  "⠀⠀⠀⡼⣷⣿⡟⣿⣿⣿⣿⣿⡟⠀⠀⠀⣀⠖⠰⢦⠤⠤⠀⠀⠀⠀⠀⠀⠀⢀⡸⣿⣿⣻⣿⣧⠀⠀⠀",
--  "⠀⠀⠀⢱⣿⣿⣿⣿⣿⣿⣿⣟⠀⠀⠀⢠⠏⠀⣾⡿⣷⡀⠀⠀⠀⠀⡾⠋⣩⡍⠁⢸⣿⣿⣻⣿⠀⠀⠀",
--  "⠀⠀⠀⡿⣿⣿⣿⣿⣿⣿⣿⣿⠰⡀⠀⢸⠀⢸⣿⣿⣿⠃⠀⠀⠀⢸⠃⢰⣿⣿⠀⢸⣿⣿⣿⣿⠄⠀⠀",
--  "⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⡇⠻⣄⠈⢧⠈⠿⠿⠋⠀⢠⣶⣤⣬⠀⢸⣿⡏⠀⢸⣿⣿⣿⠃⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣦⡈⠳⣄⡀⠀⠀⠀⠀⠀⠙⠉⠀⠁⠘⠛⢁⣰⣿⣿⣿⣿⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⣉⡳⠶⠤⣤⣀⣀⣀⣀⣀⣀⣤⣶⣿⣿⣿⣿⠏⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣿⣿⣿⣍⣿⣿⣿⣿⣿⣿⣶⣶⣶⣿⣿⣿⣷⣾⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣤⣄⣀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⢰⣤⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢧⢄⠀⠀",
-- "⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⡗⢤⢤⠾⠀",
--  "⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣽⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⠀⠀",
--  "⠀⠀⠀⠀⣸⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⠻⠟⠋⠁⠀⠀⠀⠀",
--  "⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⢀⣴⣟⠁⢸⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⢠⡾⠟⠛⠙⠳⢼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠰⢆⡀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⢀⣀⡉⢓⣦⣠⣴⠾⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀",
--  "⠀⠰⣤⣥⣼⣿⣿⡏⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠄⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠘⠹⠛⠻⠛⠃⣾⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣟⣭⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⣀⠀⠀⠀⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠋⠋⠙⣿⠻⣿⣿⣿⣿⣿⣿⣿⣿⡿⢿⣿⣯⣥⣤⣬⣽⡿⢻⣿⡏⡂⠀⠀⠀",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠏⠛⠻⠿⡿⣿⡟⢺⣿⣿⡿⠛⠛⢃⣘⠛⠛⠟⠛⠛⠻⢿⢿⠏⠙⠜⣷⢞⠂",
--  "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠆⠀⠀⠀⠁⠈⠁⢨⠭⣉⠀⠀⠀⢈⠁⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀",
--  "                                            ",
--  "                                            ",
--}


-- conf.header = {
-- "                                                       ",
-- "                                                       ",
-- "                                                       ",
-- "              ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⠿⠿⠿⠿⠿⠿⢷⣦⣄⡀⠻⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣷⣬⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⡿⠋⠀⣾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠿⣶⣶⣦⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣤⣤⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⢀⣼⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠙⠛⠿⣿⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⢀⣾⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢿⣷⣦⡀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⣾⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣤⣤⣀⠀⠀⣠⣴⣿⠿⠛⠿⣿⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣦⡀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⣰⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣾⠿⠛⠛⠛⠿⠇⠀⠙⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣆⠀⠀⠀",
-- "⠀⠀⠀⢠⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣧⠀⠀",
-- "⠀⠀⠀⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣧⠀",
-- "⠀⠀⣸⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣶⣶⣶⣦⣤⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡆",
-- "⠀⢠⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠘⣿⡇",
-- "⠀⣾⣿⠀⣰⣿⣿⣦⡀⠀⢰⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⠿⠿⠿⠿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇",
-- "⢠⣿⡇⢠⣿⣿⣿⣿⣿⣦⠀⢻⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡇",
-- "⢸⣿⠀⢸⣿⣿⣿⣿⣿⣿⣷⡀⢹⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⢸⣿⠇",
-- "⣿⣿⠀⢸⣿⣿⣿⣿⣿⣿⣿⣷⡀⢻⣇⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⢀⣾⡟⠀",
-- "⣿⣿⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⢿⡆⠀⠀⠀⠀⠀⠀⣾⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣄⣀⠀⠀⢠⣶⠿⠷⢶⣄⣤⣾⣿⠃⠀⠀⠀⢀⣾⡟⠀⠀",
-- "⣿⣿⡆⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠸⣿⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠟⠛⢿⣷⣾⣿⣿⣦⣄⡈⣿⣿⣿⡁⠀⢀⣠⣴⣿⠏⠀⠀⠀",
-- "⢿⣿⡇⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣿⡇⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣷⣤⣀⠀⠀⠀⠀⠀⢠⣿⡀⠀⠀⣿⣿⡃⠀⠈⢻⣿⡟⠋⠉⣿⣿⠿⠛⠋⠀⠀⠀⠀⠀",
-- "⢸⣿⣷⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢸⣷⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣶⣾⡿⠿⢿⣿⡇⠀⠀⢹⣿⠂⠀⢀⣼⡏⠀⠀⢀⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⢻⣿⣆⠀⢻⣿⣿⣿⣿⣿⣿⣿⡇⠀⣾⣿⣿⣶⣤⣀⡀⠀⠀⠀⠀⠀⠙⠻⠟⠛⢿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢶⠿⠿⣧⣤⣤⡾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⢻⣿⣆⠀⠻⣿⣿⣿⣿⣿⡿⠁⢰⣿⡏⠀⠈⠉⠛⠻⣷⣦⡀⠀⠀⠀⠀⠀⠀⠈⣿⣧⣤⣤⣤⡀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠹⢿⣷⣤⡀⠉⠉⠉⠉⠀⣠⣿⡿⠀⠀⠀⠀⠀⠀⠈⢻⣷⡀⠀⠀⠀⠀⠀⣴⡟⠁⠉⠛⣿⡗⠀⠀⠀⠀⢀⣀⣤⣾⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠙⠻⢿⣿⣿⣶⣾⣿⡿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣧⠀⠀⢀⣀⣤⣿⣧⠀⠀⣸⣿⠃⠀⠀⠀⢺⣿⠛⢻⣯⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣾⣿⣿⣿⠿⠟⠛⠻⣿⣀⣴⣿⠏⠀⠀⠀⠀⣼⣿⠀⠈⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢹⣿⠋⠀⠀⠀⠀⠀⣻⣿⣿⠋⠀⠀⠀⠀⢀⣿⡇⠀⢠⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⠀⠸⠿⠶⠶⠾⠟⠛⠁⠀⠀⠀⠀⠀⢸⣿⠀⠀⣼⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⠇⠀⠀⠀⢀⣤⣶⢿⣶⣦⡀⠀⠀⠀⢠⣿⡇⠀⢠⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠏⠀⠀⠀⢠⣿⠋⠀⠀⠀⠹⣿⣦⠀⢀⣾⣿⢀⣤⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡟⠀⢠⣄⣠⣿⠇⠀⠀⠀⠀⠀⣈⣿⣶⣾⣿⡿⢟⣋⣹⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⠇⠀⠈⠛⣿⣿⠀⠀⢀⣴⣾⠟⠛⠛⣿⣯⠀⠀⠀⠉⠉⠙⢿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⡿⠀⠀⠀⠀⢸⡇⠀⠀⠺⠋⠀⠀⠀⠀⠘⣿⡆⠀⠀⠀⠀⠀⠘⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⡇⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⣠⣤⣶⣿⣿⡄⠀⣴⣶⣶⣾⢿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⠀⠀⠀⠀⠀⢸⣷⠀⠀⠀⠀⠀⠺⠛⠉⠉⠉⢻⣿⡀⠉⠀⠀⠀⠀⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡿⠋⠀⠀⠀⠀⠀⠘⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣧⠀⠀⠀⠀⠀⢸⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⠀⠀⠀⠀⠀⠀⠀⠀⢹⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣇⠀⠀⠀⠀⠘⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⣻⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⡀⠀⠀⠀⠀⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⡆⠀⣶⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⠀⠀⠀⠸⣿⡇⠀⠀⠀⠀⢹⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣼⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⣸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣤⣴⠾⠛⢛⣿⣿⣿⣷⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣦⣤⣤⣤⣤⣤⣤⣤⣴⣿⣿⠿⠿⣿⣿⡿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⠛⠛⠛⠉⠁⠀⠀⢿⣿⠋⠁⠀⠈⠉⠉⠉⠉⠉⠉⠉⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⡀⠀⠀⠀⠀⠀⠀⠀⢿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣦⠀⠀⠀⠀⠀⠀⠸⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣷⣄⠀⠀⠀⠀⢀⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⣶⣶⠶⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
-- }

-- Center items. The doom theme turns every `key` into a real buffer map in the dashboard, so the
-- <Leader> hints of the global maps are written into `desc` instead (display only): a `key` like
-- "<Leader> f f" used to create bogus maps (<Space><Space>f<Space>f ...). Items that have no global
-- map get a dashboard-only single-letter `key` (buffer-local, only exists in the dashboard buffer),
-- so EVERY row shows a hint on the right. The doom theme pads every line to the longest one and
-- draws " [k]" after it, so a text hint ending in "]" lines up with the theme's own labels.
-- Every row has an icon (written as \u{} escapes: literal private-use glyphs get lost in editors)
-- so all labels start in the same column.
local WIDTH = 56

local function with_hint(name, hint)
  local label = "[" .. hint .. "]"
  return name .. (" "):rep(WIDTH - #name - #label) .. label
end

-- dashboard.nvim re-creates function actions from string.dump when the dashboard is left (cache_opts),
-- which DROPS upvalues: every action function below must only use globals (require, vim), never
-- a local helper. persistence.nvim is lazy (BufReadPre), so each action loads it on demand.

local function icon(code) return vim.fn.nr2char(code) .. "  " end

conf.center = {
  {
    icon = icon(0xf099b),
    desc = "Restore session (this folder)",
    action = function()
      require("lazy").load { plugins = { "persistence.nvim" } }
      require("persistence").load()
    end,
    key = "r",
    key_format = "[%s]",
  },
  {
    icon = icon(0xf006f),
    desc = "Restore last session",
    action = function()
      require("lazy").load { plugins = { "persistence.nvim" } }
      require("persistence").load { last = true }
    end,
    key = "L",
    key_format = "[%s]",
  },
  {
    icon = icon(0xf021e),
    desc = with_hint("Find File", "<Leader> f f"),
    action = "FzfLua files",
  },
  {
    icon = icon(0xf0222),
    desc = "Recent files here",
    -- cwd is read by fzf-lua when the item is pressed (respects :tcd)
    action = function() require("fzf-lua").oldfiles { cwd_only = true } end,
    key = "o",
    key_format = "[%s]",
  },
  {
    icon = icon(0xf0222),
    desc = with_hint("Recently opened files", "<Leader> f r"),
    action = "FzfLua oldfiles",
  },
}

-- zoxide is optional: only offer the item when the binary exists when the menu is built
if vim.fn.executable("zoxide") == 1 then
  table.insert(conf.center, {
    icon = icon(0xf024b),
    desc = "Recent directories",
    action = "FzfLua zoxide",
    key = "d",
    key_format = "[%s]",
  })
end

vim.list_extend(conf.center, {
  {
    icon = icon(0xf022c),
    desc = with_hint("Project grep", "<Leader> f g"),
    action = "FzfLua live_grep",
  },
  {
    icon = icon(0xf0645),
    desc = with_hint("Open tree view", "<Leader> s"),
    -- nvim-tree is lazy-loaded (keys <Space>s): load it, then open the tree
    action = function()
      require("lazy").load { plugins = { "nvim-tree.lua" } }
      require("nvim-tree.api").tree.open()
    end,
  },
  {
    icon = icon(0xf030c),
    desc = "Search keymaps",
    action = "FzfLua keymaps",
    key = "m",
    key_format = "[%s]",
  },
  {
    icon = icon(0xf02d6),
    desc = with_hint("Search help", "<Leader> f h"),
    action = "FzfLua helptags",
  },
  {
    icon = icon(0xf06a9),
    desc = with_hint("Claude Code", "<Leader> c c"),
    action = "ClaudeCode",
  },
  {
    icon = icon(0xf00ba),
    desc = "Open user guide",
    action = function() vim.cmd("tabnew " .. vim.fn.fnameescape(vim.fn.stdpath("config") .. "/user-guide.md")) end,
    key = "u",
    key_format = "[%s]",
  },
  {
    icon = icon(0xf0493),
    desc = with_hint("Open Nvim config", "<Leader> e v"),
    action = "tabnew $MYVIMRC | tcd %:p:h",
  },
  {
    icon = icon(0xf0752),
    desc = "New file",
    action = "enew",
    key = "e",
    key_format = "[%s]",
  },
  {
    icon = icon(0xf05fc),
    desc = "Quit Nvim",
    action = "qa",
    key = "q",
    key_format = "[%s]",
  },
})

-- Header: pick an art that leaves room for the whole menu on THIS window (the menu is two lines per
-- item, plus footer and padding); try a few random ones and keep the first that fits, else the
-- shortest seen (the dashboard window then simply scrolls with the cursor). Blank lines after the
-- art separate it from the menu.
local PAD = 3
local function pick_header()
  local room = vim.o.lines - 2 * #conf.center - 4 - PAD
  local best
  for _ = 1, 40 do
    local art = ascii.get_random_global()
    if art then
      local wide = 0
      for _, l in ipairs(art) do wide = math.max(wide, vim.fn.strdisplaywidth(l)) end
      if #art <= room and wide <= vim.o.columns then return art end
      if not best or #art < #best then best = art end
    end
  end
  return best or {}
end

conf.header = vim.list_extend(vim.deepcopy(pick_header()), vim.fn["repeat"]({ "" }, PAD))

dashboard.setup {
  theme = "doom",
  shortcut_type = "number",
  config = conf,
}
