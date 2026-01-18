Config.HouseIpls = {
	-- HouseIpls:
	-- key               = unique IPL interior identifier
	-- label             = name shown in UI
	-- tags              = tags used for filtering (Furnished, Apartment, etc.)
	-- exitcoords        = exit position inside the interior
	-- managmentcoords   = property management interaction position
	-- wardrobecoords    = wardrobe interaction position
	-- storagecoords     = storage interaction position
	-- cookcoords        = kitchen interaction position
	-- sinkcoords        = sink interaction positions
	-- showercoords      = shower interaction positions
	-- cleanpoints       = cleaning interaction positions
	-- images            = preview images shown in UI
	-- themes            = selectable interior themes (IPL variants)

	-- Themes:
	-- id                = theme identifier
	-- label             = theme name shown in UI
	-- ipl               = IPL name to load
	-- interiorId        = interior ID used for enabling/disabling props
    ["eclipse1"] = {
        label = "Eclipse 1",
		tags = {"Furnished", "Apartment"},
		exitcoords = {coords = vector3(-785.45, 314.41, 216.63), heading = 10.5},
		managmentcoords = {coords = vector3(-781.00732421875, 315.64797973633, 217.13844299316)},
		wardrobecoords = {coords = vector3(-795.5791015625, 326.44375610352, 216.53811645508)},
		storagecoords = {coords = vector3(-788.64605712891, 320.94747924805, 216.53811645508)},	
		cookcoords = {coords = vector3(-782.27368164062, 329.07217407227, 216.53811645508)},
		sinkcoords = {{coordswater = vector3(0.0, 0.0, 0.0), coordsplayer = vector3(0.0, 0.0, 0.0), heading = 0.0}},
		showercoords = {{coordswater = vector3(0.0, 0.0, 0.0), coordsplayer = vector3(0.0, 0.0, 0.0), heading = 0.0}},
		cleanpoints = {
			 {coords = vector3(-797.02917480469, 324.79379272461, 216.03811645508)},
			 {coords = vector3(-788.22717285156, 324.48815917969, 216.03811645508)},
			 {coords = vector3(-787.60412597656, 328.89440917969, 216.03826904297)},
			 {coords = vector3(-789.81811523438, 340.08303833008, 215.8384552002)},
		},		
		images = {
			{url = "img/previewimages/eclipse1_1.webp"},
			{url = "img/previewimages/eclipse1_2.webp"},
			{url = "img/previewimages/eclipse1_3.webp"},
		},
		themes = {
			{
				id = "modern",
				label = "Modern",
				ipl = "apa_v_mp_h_01_a",
				interiorId = 227329
			},
			{
				id = "moody",
				label = "Moody",
				ipl = "apa_v_mp_h_02_a",
				interiorId = 228097
			},
			{
				id = "vibrant",
				label = "Vibrant",
				ipl = "apa_v_mp_h_03_a",
				interiorId = 228865
			},
			{
				id = "sharp",
				label = "Sharp",
				ipl = "apa_v_mp_h_04_a",
				interiorId = 229633
			},
			{
				id = "monochrome",
				label = "Monochrome",
				ipl = "apa_v_mp_h_05_a",
				interiorId = 230401
			},
			{
				id = "seductive",
				label = "Seductive",
				ipl = "apa_v_mp_h_06_a",
				interiorId = 231169
			},
			{
				id = "regal",
				label = "Regal",
				ipl = "apa_v_mp_h_07_a",
				interiorId = 231937
			},
			{
				id = "aqua",
				label = "Aqua",
				ipl = "apa_v_mp_h_08_a",
				interiorId = 232705
			}
        },
    },

    ["highend1"] = {
        label = "High End 1",
		tags = {"Furnished", "Apartment"},
		exitcoords = {coords = vector3(-174.26, 497.73, 136.65), heading = 182.0},
		managmentcoords = {coords = vector3(-174.20851135254, 492.32666015625, 137.15361022949)},
		wardrobecoords = {coords = vector3(-170.57931518555, 482.78353881836, 136.74415588379)},
		storagecoords = {coords = vector3(-171.1088104248, 486.74038696289, 136.94355773926)},		
		cookcoords = {coords = vector3(-167.2857208252, 494.6799621582, 137.15357971191)},
		sinkcoords = {{coordswater = vector3(0.0, 0.0, 0.0), coordsplayer = vector3(0.0, 0.0, 0.0), heading = 0.0}},
		showercoords = {{coordswater = vector3(0.0, 0.0, 0.0), coordsplayer = vector3(0.0, 0.0, 0.0), heading = 0.0}},
		cleanpoints = {
			 {coords = vector3(-173.29139709473, 494.29821777344, 136.67207336426)},
			 {coords = vector3(-170.21482849121, 489.9098815918, 136.44355773926)},
			 {coords = vector3(-169.48823547363, 482.19833374023, 136.24415588379)},
			 {coords = vector3(-177.02905273438, 492.75036621094, 136.65361022949)},
		},		
		images = {
			{url = "img/previewimages/highend1_1.webp"},
			{url = "img/previewimages/highend1_2.webp"},
			{url = "img/previewimages/highend1_3.webp"},
		},
		themes = {
			{
				id = "modern",
				label = "Modern",
				ipl = "apa_v_mp_h_01_a",
				interiorId = ""
			},
			{
				id = "moody",
				label = "Moody",
				ipl = "apa_v_mp_h_02_a",
				interiorId = ""
			},
			{
				id = "vibrant",
				label = "Vibrant",
				ipl = "apa_v_mp_h_03_a",
				interiorId = ""
			},
			{
				id = "sharp",
				label = "Sharp",
				ipl = "apa_v_mp_h_04_a",
				interiorId = ""
			},
			{
				id = "monochrome",
				label = "Monochrome",
				ipl = "apa_v_mp_h_05_a",
				interiorId = ""
			},
			{
				id = "seductive",
				label = "Seductive",
				ipl = "apa_v_mp_h_06_a",
				interiorId = ""
			},
			{
				id = "regal",
				label = "Regal",
				ipl = "apa_v_mp_h_07_a",
				interiorId = ""
			},
			{
				id = "aqua",
				label = "Aqua",
				ipl = "apa_v_mp_h_08_a",
				interiorId = ""
			}
        },
    },
}