Config = {}

Config.CaptureCooldown = 14400 --- 4 hours
Config.BlockVehicleInTerritory = true
Config.Territories = {
    BURRITO = {
        label = "EL Burrito Heights",
        washzone = false,
        radius = 100.00,
        RewardMoney = 300000,
        capture = { 
            location = vec3(1636.42, -1884.43, 106.52),
            lastCaptureTime  = 0, --- 4 hours
            captureTime = 0.2 -- minutes.
        },
        CollectZones = {
        }
    },
    ELYSIAN = {
        label = "Elysian Island",
        washzone = false,
        drugs = "meth",
        RewardMoney = 0,
        radius = 100.00,
        capture = { 
            location = vec3(140.94, -3094.0, 5.9),
            lastCaptureTime  = 0,
            captureTime = 20 -- minutes.
        },
        CollectZones = {
        }
    },
    STAB = {
        label = "Stab City",
        washzone = false,
        RewardMoney = 250000,
        radius = 100.00,
        capture = { 
            location = vec3(63.5, 3714.05, 39.75),
            lastCaptureTime  = 0, 
            captureTime = 0.3 -- minutes.
        },
        CollectZones = {
        }
    },
    KORTZ = {
        label = "Kortz Center",
        radius = 100.00,
        washzone = true,
        RewardMoney = 250000,
        capture = {
            location = vec3(-2239.56, 258.89, 174.6),
            lastCaptureTime = 0,
            captureTime = 20
        },
        CollectZones = {
        }
    },

    GRAPESEED = {
        label = "Grapeseed",
        radius = 100.00,
        washzone = true,
        RewardMoney = 250000,
        capture = {
            location = vec3(2438.39, 4980.55, 46.57),
            lastCaptureTime = 0,
            captureTime = 20
        },
        CollectZones = {
        }
    },
}


Config.Gangs = {
    santo = { color = 3},
    geng = { color = 9},
    geng2 = { color = 8},
}
