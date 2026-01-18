Config.Deliveries = {
	-- Deliveries:
	-- id            = unique delivery service identifier
	-- name          = service name shown in UI
	-- description   = short service description
	-- useCart       = enable shopping cart system
	-- allowQuantity = allow ordering multiple quantities
	-- icon          = FontAwesome icon used in UI
	-- items         = list of purchasable items

	-- Delivery items:
	-- id            = item name
	-- title         = item name shown in UI
	-- description   = item description
	-- price         = item price
	-- image         = optional image path (used for dancers)
	-- useImage      = if true, image is shown instead of icon
	{
		id            = "cluckinbell",
		name          = "Cluckin’ Bell",
		description   = "When hunger strikes, Cluckin’ Bell delivers the knockout.",
		useCart       = true,
		allowQuantity = true,
		icon          = "fa-drumstick-bite",
		items = {
			-- Classic Chicken
			{ id = "fustercluck",      title = "Fustercluck Meal",      description = "10pc nuggets + fries + regret", price = 28},
			{ id = "cluckinsalad",     title = "Cluckin’ Salad",        description = "Lettuce with a side of lies", price = 22},
			{ id = "bleederbucket",    title = "Bleeder Bucket",        description = "20pc wings. Bring napkins.", price = 45},
			{ id = "chickenburger",    title = "Cluckin’ Big Burger",   description = "Two patties, zero clucks given", price = 32},

			-- San Andreas Easter Eggs
			{ id = "sa_heartstopper",  title = "Heart Stopper",         description = "SA classic. Triple bypass included", price = 38},
			{ id = "sa_moneyshot",     title = "Money Shot",            description = "So greasy it pays rent", price = 42},

			-- Sides & Sauces
			{ id = "cluckinfries",     title = "Cluckin’ Fries",        description = "Salted by tears of the health-conscious", price = 10},
			{ id = "chickentenders",   title = "Tenders (6pc)",         description = "Dippable sadness", price = 25},
			{ id = "cb_ranch",         title = "Cluckin’ Ranch",       description = "White. Creamy. Essential.", price = 4},
			{ id = "cb_bbq",           title = "BBQ Sauce",             description = "Sweet, smoky, slightly radioactive", price = 4},

			-- Drinks
			{ id = "sprunk_large",     title = "Large Sprunk",          description = "64oz of pure lemon-lime violence", price = 6},
			{ id = "ecola_large",      title = "Large eCola",           description = "Diabetes in a cup. Refills free.", price = 6},
		}
	},
		{
		id            = "burgershot",
		name          = "Burger Shot",
		description   = "Burgers so good you’ll forget what you were running from.",
		useCart       = true,
		allowQuantity = true,
		icon          = "fa-burger",

		items = {
			-- Burgers
			{ id = "heartstopper",     title = "Heart Stopper",         description = "Quadruple patty. Doctor not included", price = 40},
			{ id = "moneyshot",        title = "Money Shot",            description = "Grease drips like a supercar", price = 38},
			{ id = "doublecheese",     title = "Double Cheese",         description = "Two patties, one dream", price = 28},
			{ id = "babyshot",         title = "Baby Shot",             description = "Kid-sized… still lethal", price = 18},

			-- San Andreas Nostalgia
			{ id = "sa_beef_tower",    title = "Beef Tower",            description = "SA legend. 6 patties. Send help.", price = 55},
			{ id = "sa_meat_stack",    title = "Meat Stack",            description = "They said it couldn’t be done", price = 48},

			-- Sides & Extras
			{ id = "bs_fries",         title = "Burger Shot Fries",     description = "Salted with worker tears", price = 10},
			{ id = "onionrings",       title = "Onion Rings",           description = "Crispy halos of guilt", price = 14},
			{ id = "bs_shake",         title = "Thick Shake",           description = "Straw not included (too thick)", price = 12},
			{ id = "bs_toy",           title = "Kid’s Meal Toy",        description = "Choking hazard + nostalgia", price = 5},

			-- Drinks
			{ id = "pisswasser_bs",    title = "Pißwasser (Can)",       description = "Breakfast of champions", price = 8},
			{ id = "sprunk_bs",        title = "Sprunk (Can)",          description = "Now with extra fizz and lies", price = 5},
		}
	},
	{
		id            = "pizzathis",
		name          = "Pizza This",
		description   = "Where every pizza is a perfect blend of chaos and cheese.",
		useCart       = true,
		allowQuantity = true,
		icon          = "fa-pizza-slice",

		items = {
			-- Classic Pizzas
			{ id = "pizza_margherita",   title = "Margherita",           description = "Tomato, cheese, and false hope", price = 28},
			{ id = "pizza_pepperoni",    title = "Pepperoni Feast",      description = "Greasy circles on greasy circles", price = 35},
			{ id = "pizza_meatlover",    title = "Meat Lover’s",         description = "Heart attack in a box – extra bacon", price = 42},
			{ id = "pizza_hawaiian",     title = "Hawaiian Special",     description = "Pineapple on pizza. Fight me.", price = 32},
			{ id = "pizza_veggie",       title = "Veggie Delight",       description = "Now with 30% more sadness", price = 30},

			-- Specialty Chaos
			{ id = "pizza_bleeder",      title = "The Bleeder",          description = "So much sauce it leaks through the box", price = 45},
			{ id = "pizza_chiliad",      title = "Mount Chiliad Monster", description = "Quadruple cheese, zero regrets", price = 55},
			{ id = "pizza_pisswasser",   title = "Pißwasser Pie",        description = "Beer-infused crust. Don’t ask.", price = 40},
			{ id = "pizza_mystery",      title = "Mystery Topping",      description = "Chef’s choice. Could be anything.", price = 25},

			-- Sides & Extras
			{ id = "garlicbread",        title = "Garlic Bread",         description = "Vampire repellent, breath destroyer", price = 15},
			{ id = "chickenwings",       title = "Hot Wings (6pc)",      description = "Spicy enough to make you cry", price = 22},
			{ id = "cheesesticks",       title = "Cheesy Bread Sticks",  description = "Just cheese pretending to be bread", price = 18},
			{ id = "ranchdip",           title = "Ranch Dip",            description = "White gold. Don’t judge us.", price = 5},
			{ id = "ecola2l",            title = "2L eCola",             description = "Because one liter isn’t enough", price = 8},
		}
	},			
	{
		id            = "gloceriesstore",
		name          = "24/7",
		description   = "Snacks, drinks, essentials — delivered faster than you can say chaos.",
		useCart       = true,
		allowQuantity = true,
		icon          = "fa-basket-shopping",

		items = {
			-- Drinks
			{ id = "sprunk",            title = "Sprunk",              description = "Lemon-lime chaos in a can", price = 3},
			{ id = "ecola",             title = "eCola",               description = "Now with 200% more chemicals", price = 3},
			{ id = "ecola_light",       title = "eCola Light",         description = "Tastes exactly the same, somehow", price = 3},
			{ id = "pisswasser",        title = "Pißwasser Beer",      description = "Imported regret, now in cans", price = 5},
			{ id = "pisswasser_light",  title = "Pißwasser Light",     description = "For people lying to themselves", price = 5},
			{ id = "orangotang",        title = "Orang-O-Tang Juice",  description = "2% fruit, 98% lies", price = 4},

			-- Snacks & Candy
			{ id = "egochaser",         title = "EgoChaser Bar",       description = "Only winners allowed", price = 6},
			{ id = "meteorite",         title = "Meteorite Bar",       description = "Chocolate + mystery crunch", price = 4},
			{ id = "psandqs",           title = "P’s & Q’s Candy",     description = "Will rot your teeth in style", price = 3},
			{ id = "rustydonuts",       title = "Rusty Brown’s Donuts", description = "Box of 6 questionable circles", price = 8},
			{ id = "cherenkovchips",    title = "Cherenkov Chips",     description = "Glows in the dark, slightly illegal", price = 4},
			{ id = "cornuts",           title = "Cornuts Snack Mix",   description = "Salty enough to summon thirst demons", price = 3},
			{ id = "beefjerky",         title = "Slaughterhouse Jerky", description = "Chewier than your ex’s excuses", price = 10},

			-- Groceries / Food Basics
			{ id = "milk",              title = "2% Dairy-ish Milk",   description = "Dairy-adjacent liquid", price = 5},
			{ id = "bread",             title = "Loaf of Bread",       description = "Soft…ish. Probably", price = 4},
			{ id = "beans",             title = "Canned Bean Surprise", description = "Surprise = sodium overdose", price = 3},
			{ id = "apple",             title = "Organic-ish Apple",   description = "One apple = doctor stays broke", price = 2},

			-- Misc. / Everyday Stuff
			{ id = "redwood",           title = "Redwood Cigarettes",  description = "Official smoke of Los Santos", price = 12},
			{ id = "debonaire",         title = "Debonaire Cigarettes", description = "For people who pay to look cool", price = 18},
		}
	},
	{
		id            = "liqour",
		name          = "Liquor Market",
		description   = "Your doorstep source of booze, vibes, and questionable decisions.",
		useCart       = true,
		allowQuantity = true,
		icon          = "fa-wine-bottle",

		items = {
			-- Hard Liquor
			{ id = "bleedinwhiskey",   title = "Bleedin’ Whiskey",     description = "Burns twice, regrets thrice", price = 45},
			{ id = "blainebourbon",    title = "Blaine County Bourbon", description = "Locally feared, locally loved", price = 50},
			{ id = "lspremiumvodka",   title = "LS Premium Vodka",     description = "Premium because the label says so", price = 40},
			{ id = "northernvodka",    title = "Northern Lights Vodka", description = "Dangerously clear, dangerously strong", price = 55},
			{ id = "chiliadrum",       title = "Mount Chiliad Spiced Rum", description = "Kick + regret in every sip", price = 48},
			{ id = "ronsgin",          title = "Ron’s Reserve Gin",    description = "Tastes like Christmas tree & despair", price = 42},
			{ id = "coyoteteq",        title = "Coyote Tequila",       description = "Cheap, huge, and full of bad ideas", price = 35},
			{ id = "desperadogold",    title = "Desperado Gold Tequila", description = "Smoother… still trouble", price = 70},
			{ id = "libcitygin",       title = "Liberty City Dry Gin", description = "Sharp, dry, and overpriced", price = 60},

			-- Beer & Ale
			{ id = "pisswasser6",      title = "Pißwasser 6-Pack",     description = "Official sponsor of poor decisions", price = 18},
			{ id = "pisswasser_light", title = "Pißwasser Light",      description = "Same shame, fewer calories", price = 16},
			{ id = "logger",           title = "Logger Beer",          description = "For the working man (real or fake)", price = 20},
			{ id = "duschegold",       title = "Dusche Gold",          description = "Thinks it’s fancy. It’s not.", price = 25},
			{ id = "blarneys",         title = "Blarneys Irish Lager", description = "Irish-inspired chaos in a bottle", price = 22},
			{ id = "benedict",         title = "Benedict Pale Ale",    description = "Craft beer for people who can’t afford craft", price = 28},

			-- Wine & Champagne
			{ id = "rockfordred",      title = "Rockford Hill Red",    description = "Looks expensive, tastes like Tuesday", price = 30},
			{ id = "vinewoodrose",     title = "Vinewood Hills Rosé",  description = "Pink, sweet, influencer-approved", price = 35},
			{ id = "boxwine",          title = "Budget Box Wine",      description = "3 liters of courage in cardboard", price = 25},
			{ id = "goldenfizz",       title = "Golden Fizz Champagne", description = "Bubbles for fake celebrations", price = 80},

			-- Ready-to-Drink & Mixers
			{ id = "sprunkmix",        title = "Sprunk Mix",           description = "Liquid sugar for DIY disasters", price = 5},
			{ id = "ecolamixer",       title = "eCola Mixer",          description = "Hides the taste of everything", price = 6},
			{ id = "premojito",        title = "Pre-Mixed Mojito Can", description = "Minty regret, ready to go", price = 10},
			{ id = "whiskeycola",      title = "Whiskey Cola Can",     description = "Acceptable when ice-cold", price = 9},
			{ id = "rageenergy",       title = "RaGe Energy Drink",    description = "3 hours sleep? Challenge accepted", price = 8},

			-- Bar Snacks
			{ id = "banditpeanuts",    title = "Salted Bandit Peanuts", description = "Engineered to make you thirstier", price = 4},
			{ id = "cherenkovchips",   title = "Cherenkov Chips",      description = "Spicy, glowing, mildly radioactive", price = 5},
			{ id = "beefjerky",        title = "Slaughterhouse Jerky", description = "Chews longer than your friendships", price = 12},
			{ id = "cheesecrackle",    title = "Cheese Crackle Bites", description = "So loud the neighbors complain", price = 5},

			-- Misc
			{ id = "lighter",          title = "Disposable Lighter",   description = "Works 7 out of 10 times", price = 2},
			{ id = "lotto",            title = "Scratch Lotto Ticket", description = "99.9% excitement, 0.1% payout", price = 10},
		}
	},    
	{
		id            = "dancers",
		name          = "Dancers",
		description   = "When the streets calm down, Dancers heats up.",
		useCart       = false,
		allowQuantity = false,
		icon          = "fa-person-dress",

		items = {
			-- VIP Lap Dances
			{ id = "dancer1",    title = "Fufu",     description = "The queen of slow grinds",                      price = 500,  image = "img/dancers/dancer1.webp",    useImage = true },
			{ id = "dancer2",      title = "Juliet",       description = "Flexible and expensive",                        price = 600,  image = "img/dancers/dancer2.webp",      useImage = true },
			{ id = "dancer3", title = "Sapphire",  description = "She’ll make your credits disappear",             price = 750,  image = "img/dancers/dancer3.webp", useImage = true },
			{ id = "dancer4",  title = "Peach",   description = "Sweet name, dangerous moves",                   price = 650,  image = "img/dancers/dancer4.webp",  useImage = true },
			{ id = "dancer5", title = "Chastity",  description = "She’ll rob you blind… and you’ll thank her",    price = 1000, image = "img/dancers/dancer5.webp", useImage = true },
			{ id = "dancer6",   title = "Nikki",    description = "Michael's ex-pole queen. Trevor approved.",      price = 1200, image = "img/dancers/dancer6.webp",   useImage = true },  
		}
	},
}

Config.Dancers = {
	-- NPC dancer definitions used by the Dancers delivery service.
	["dancer1"] = {
		model = "s_f_y_stripper_02",
		componentvariations = {
			[1] = {componenttype = 2, drawableid = 2, textureid = 0, paletteid = 0}, 
		}
	},
	["dancer2"] = {
		model = "s_f_y_stripper_02",
		componentvariations = {
			[1] = {componenttype = 3, drawableid = 0, textureid = 0, paletteid = 0}, 
		}
	},	
	["dancer3"] = {
		model = "s_f_y_hooker_01",
		componentvariations = {
			[1] = {componenttype = 0, drawableid = 0, textureid = 0, paletteid = 0},  
		}
	},		
	["dancer4"] = {
		model = "s_f_y_hooker_02",
		componentvariations = {
			[1] = {componenttype = 0, drawableid = 0, textureid = 0, paletteid = 0}, 
		}
	},	
	["dancer5"] = {
		model = "s_f_y_hooker_03",
		componentvariations = {
			[1] = {componenttype = 0, drawableid = 0, textureid = 0, paletteid = 0}, 
		}
	},		
	["dancer6"] = {
		model = "s_f_y_stripper_01",
		componentvariations = {
			[1] = {componenttype = 0, drawableid = 0, textureid = 0, paletteid = 0}, 
		}
	},				
}


Config.DancerDances = {
	-- Animation list used for dancer performances.
	[1] = {
		animdict = "mini@strip_club@lap_dance@ld_girl_a_song_a_p1",
		animname = "ld_girl_a_song_a_p1_f",
	},
	[2] = {
		animdict = "mini@strip_club@private_dance@idle",
		animname = "priv_dance_idle",
	},	
	[3] = {
		animdict = "mini@strip_club@lap_dance@ld_girl_a_song_a_p3",
		animname = "ld_girl_a_song_a_p3_f",
	},		
	[4] = {
		animdict = "mini@strip_club@private_dance@part1",
		animname = "priv_dance_p1",
	},	
	[5] = {
		animdict = "mini@strip_club@private_dance@part3",
		animname = "priv_dance_p3",
	},		
	[6] = {
		animdict = "oddjobs@assassinate@multi@yachttarget@lapdance",
		animname = "yacht_ld_f",
	},			
}