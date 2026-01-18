Config.KitchenRecipes = {
	-- KitchenRecipes:
	-- id            = unique recipe identifier (used internally)
	-- title         = recipe name shown in the UI
	-- description   = short description shown in the UI
	-- time          = cooking time in seconds
	-- energycost    = electricity usage per recipe
	-- ingredients   = list of required items (item name, label, amount)
    {
        id          = "spaghetti",
        title       = "Spaghetti",
        description = "Classic pasta with tomato sauce.",
        time        = 12,
		energycost = 0.25,
        ingredients = {
            { item = "pasta",  label = "Pasta",  amount = 1 },
            { item = "tomato", label = "Tomato", amount = 1 },
            { item = "salt",   label = "Salt",   amount = 1 },
        }
    },
    {
        id          = "cheeseburger",
        title       = "Cheeseburger",
        description = "Grilled patty with cheese in a bun.",
        time        = 14,
		energycost = 0.25,
        ingredients = {
            { item = "bread",  label = "Bread",  amount = 1 },
            { item = "meat",   label = "Meat",   amount = 1 },
            { item = "cheese", label = "Cheese", amount = 1 },
        }
    },
    {
        id          = "tomato_soup",
        title       = "Tomato Soup",
        description = "Warm classic tomato soup.",
        time        = 10,
		energycost = 0.25,
        ingredients = {
            { item = "tomato", label = "Tomato", amount = 2 },
            { item = "salt",   label = "Salt",   amount = 1 },
        }
    },
    {
        id          = "fried_egg",
        title       = "Fried Egg",
        description = "Simple breakfast meal.",
        time        = 5,
		energycost = 0.25,
        ingredients = {
            { item = "egg",    label = "Egg",    amount = 1 },
            { item = "butter", label = "Butter", amount = 1 },
        }
    },
    {
        id          = "toast",
        title       = "Toast",
        description = "Pan-toasted slice of bread.",
        time        = 4,
		energycost = 0.25,
        ingredients = {
            { item = "bread",  label = "Bread",  amount = 1 },
            { item = "butter", label = "Butter", amount = 1 },
        }
    },
    {
        id          = "grilled_steak",
        title       = "Grilled Steak",
        description = "Seasoned and grilled to perfection.",
        time        = 16,
		energycost = 0.25,
        ingredients = {
            { item = "meat",   label = "Meat",   amount = 1 },
            { item = "salt",   label = "Salt",   amount = 1 },
            { item = "pepper", label = "Pepper", amount = 1 },
        }
    },
    {
        id          = "omelette",
        title       = "Omelette",
        description = "Soft folded egg omelette.",
        time        = 8,
		energycost = 0.25,
        ingredients = {
            { item = "egg",    label = "Egg",    amount = 2 },
            { item = "cheese", label = "Cheese", amount = 1 },
        }
    },
    {
        id          = "mac_and_cheese",
        title       = "Mac & Cheese",
        description = "Creamy pasta with melted cheese.",
        time        = 13,
		energycost = 0.25,
        ingredients = {
            { item = "pasta",  label = "Pasta",  amount = 1 },
            { item = "cheese", label = "Cheese", amount = 1 },
            { item = "butter", label = "Butter", amount = 1 },
        }
    },
    {
        id          = "meatballs",
        title       = "Meatballs",
        description = "Seasoned ground-meat balls.",
        time        = 11,
		energycost = 0.25,
        ingredients = {
            { item = "meat",   label = "Meat",   amount = 1 },
            { item = "salt",   label = "Salt",   amount = 1 },
            { item = "pepper", label = "Pepper", amount = 1 },
        }
    },
    {
        id          = "grilled_cheese",
        title       = "Grilled Cheese",
        description = "Melted cheese between crisp bread.",
        time        = 7,
		energycost = 0.25,
        ingredients = {
            { item = "bread",  label = "Bread",  amount = 1 },
            { item = "cheese", label = "Cheese", amount = 1 },
            { item = "butter", label = "Butter", amount = 1 },
        }
    },
}

Config.CookingAnim = {
	dict = "rtx_djn_housing_simple_cooking", -- Animation dictionary used while cooking
	name = "simplecooking" -- Animation name played during cooking
}
