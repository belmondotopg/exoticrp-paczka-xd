Config = {}
Config.Command = "swieta"
Config.Products = {
    {
        id = "money",
        name = "$50,000",
        count = 1,
        price = 10,
        allowMultipleClaims = true,
        image = "https://cdn.pixabay.com/animation/2023/06/08/15/03/15-03-45-927_512.gif",
        claimFunction = function(src)
            exports.ox_inventory:AddItem(src, 'money', 50000)
        end
    },
    {
        id = "car",
        name = "Lamborghini Urus",
        count = 1,
        price = 30,
        allowMultipleClaims = false,
        image = "https://i.ibb.co/WvZ8QksF/urus.png",
        claimFunction = function(src)
            functions.saveVehicleToGarage(src, "vc_exoticurus1016")
        end
    },
}