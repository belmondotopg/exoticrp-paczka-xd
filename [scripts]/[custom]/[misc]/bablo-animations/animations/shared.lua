Config.Shared = {
    {
        category = "shared",
        type = "shared",
        name = "slapsomeone",
        label = "Policzek",
        requester = {
            lib = "melee@unarmed@streamed_variations",
            animation = "victim_takedown_front_slap",
            flag = 2,
            ragdoll = true
        },
        accepter = {
            lib = "melee@unarmed@streamed_variations",
            animation = "plyr_takedown_front_slap",
            label = "",
            skip = false,
            flag = 11,
            attach = {
                bone = 9816,
                xPosition = 0.0,
                yPosition = 1.0,
                zPosition = 0.0,
                xRotation = 0.0,
                yRotation = 0.0,
                zRotation = 180.0,
            }
        }
    },
    {
        category = "shared",
        type = "shared",
        name = "headbuttsomeone",
        label = "Cios głową",
        requester = {
            lib = "melee@unarmed@streamed_variations",
            animation = "victim_takedown_front_headbutt",
            flag = 2,
            ragdoll = true
        },
        accepter = {
            lib = "melee@unarmed@streamed_variations",
            animation = "plyr_takedown_front_headbutt",
            label = "",
            skip = false,
            flag = 11,
            attach = {
                bone = 9816,
                xPosition = 0.0,
                yPosition = 1.0,
                zPosition = 0.0,
                xRotation = 0.0,
                yRotation = 0.0,
                zRotation = 180.0,
            }
        }
    },
    {
        category = "shared",
        type = "shared",
        name = "givehug",
        label = "Uścisk",
        requester = {
            lib = "mp_ped_interaction",
            animation = "kisses_guy_a",
            flag = 0,
            ragdoll = false
        },
        accepter = {
            lib = "mp_ped_interaction",
            animation = "kisses_guy_b",
            label = "Uścisk z osobą",
            skip = false,
            flag = 0,
            attach = {
                bone = 9816,
                xPosition = 0.05,
                yPosition = 1.15,
                zPosition = -0.05,
                xRotation = 0.0,
                yRotation = 0.0,
                zRotation = 180.0,
            }
        }
    },

    {
        category = "shared",
        type = "shared",
        name = "highfive",
        label = "Przybij piątkę",
        requester = {
            lib = "mp_ped_interaction",
            animation = "highfive_guy_a",
            flag = 0
        },
        accepter = {
            lib = "mp_ped_interaction",
            animation = "highfive_guy_b",
            label = "Przybij piątkę z osobą",
            flag = 0,
            attach = {
                bone = 9816,
                xPosition = -0.5,
                yPosition = 1.25,
                zPosition = 0.0,
                xRotation = 0.9,
                yRotation = 0.3,
                zRotation = 180.0,
            }
        }
    },

    {
        category = "shared",
        type = "shared",
        name = "brotherlyhug",
        label = "Braterski Uścisk",
        requester = {
            lib = "mp_ped_interaction",
            animation = "hugs_guy_a",
            flag = 0
        },
        accepter = {
            lib = "mp_ped_interaction",
            animation = "hugs_guy_b",
            label = "Zrób braterski uścisk z osobą",
            flag = 0,
            attach = {
                bone = 9816,
                xPosition = -0.025,
                yPosition = 1.15,
                zPosition = 0.0,
                xRotation = 0.0,
                yRotation = 0.0,
                zRotation = 180.0,
            }
        }
    },
    {
        category = "shared",
        type = "shared",
        name = "fistbump",
        label = "Zderzenie Pięści",
        requester = {
            lib = "anim@mp_player_intcelebrationpaired@f_f_fist_bump",
            animation = "fist_bump_left",
            flag = 0
        },
        accepter = {
            lib = "anim@mp_player_intcelebrationpaired@f_f_fist_bump",
            animation = "fist_bump_right",
            label = "Zderzenie pięści z osobą",
            flag = 0,
            attach = {
                bone = 9816,
                xPosition = -0.6,
                yPosition = 0.9,
                zPosition = 0.0,
                xRotation = 0.0,
                yRotation = 0.0,
                zRotation = 270.0,
            }
        }
    },

    {
        category = "shared",
        type = "shared",
        name = "handshakesomeone",
        label = "Uścisk Dłoni",
        requester = {
            lib = "mp_ped_interaction",
            animation = "handshake_guy_a",
            flag = 0
        },
        accepter = {
            lib = "mp_ped_interaction",
            animation = "handshake_guy_b",
            label = "Uściśnij dłoń z osobą",
            flag = 0,
            attach = {
                bone = 9816,
                xPosition = 0.0,
                yPosition = 1.2,
                zPosition = 0.0,
                xRotation = 0.0,
                yRotation = 0.0,
                zRotation = 180.0,
            }
        }
    },
    {
        category = "shared",
        type = "shared",
        name = "formalhandshake",
        label = "Uścisk Dłoni (Formalny)",
        requester = {
            lib = "mp_common",
            animation = "givetake1_a",
            flag = 0
        },
        accepter = {
            lib = "mp_common",
            animation = "givetake1_b",
            label = "Uściśnij dłoń z osobą",
            flag = 0,
            attach = {
                bone = 9816,
                xPosition = 0.075,
                yPosition = 1.0,
                zPosition = 0.0,
                xRotation = 0.0,
                yRotation = 0.0,
                zRotation = 180.0,
            }
        }
    },
}
