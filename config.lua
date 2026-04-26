Config = {}

Config.Debug = false

Config.ResourceName = 'distortionz_cityhall'
Config.CurrentVersion = '1.0.0'

Config.VersionCheck = {
    enabled = true,
    url = 'https://raw.githubusercontent.com/Distortionzz/Distortionz_Cityhall/main/version.json',
    checkOnStart = true
}

Config.Notify = {
    title = 'City Hall',
    useDistortionzNotify = true
}

Config.CityHall = {
    ped = {
        enabled = true,
        model = 's_m_m_highsec_01',
        coords = vec4(-545.31, -204.84, 38.22, 208.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    },

    target = {
        icon = 'fa-solid fa-landmark',
        label = 'Open City Hall',
        distance = 2.5
    },

    blip = {
        enabled = true,
        sprite = 498,
        colour = 5,
        scale = 0.8,
        label = 'City Hall',
        shortRange = true
    }
}

Config.Money = {
    account = 'cash',
    allowBankFallback = true,
    fallbackAccount = 'bank'
}
Config.Identity = {
    {
        id = 'id_card',
        label = 'State ID Card',
        description = 'Official government-issued identification card.',
        icon = 'id-card',
        price = 250,
        metadataKey = 'id',
        item = 'id_card',
        giveItem = true,
        enabled = true
    },
    {
        id = 'driver_license',
        label = 'Driver License',
        description = 'Required to legally operate motor vehicles.',
        icon = 'car',
        price = 500,
        metadataKey = 'driver',
        item = 'driver_license',
        giveItem = true,
        enabled = true
    },
    {
        id = 'weapon_license',
        label = 'Weapon License',
        description = 'Required for legal firearm ownership.',
        icon = 'shield',
        price = 2500,
        metadataKey = 'weapon',
        item = 'weaponlicense',
        giveItem = true,
        enabled = true
    }
}

Config.Permits = {
    {
        id = 'business_permit',
        label = 'Business Permit',
        description = 'Required to register or operate a legal business.',
        icon = 'briefcase',
        price = 5000,
        metadataKey = 'business',
        enabled = true
    },
    {
        id = 'hunting_permit',
        label = 'Hunting Permit',
        description = 'Allows legal hunting activity where permitted.',
        icon = 'crosshair',
        price = 1200,
        metadataKey = 'hunting',
        enabled = true
    },
    {
        id = 'fishing_permit',
        label = 'Fishing Permit',
        description = 'Allows legal fishing activity where permitted.',
        icon = 'fish',
        price = 750,
        metadataKey = 'fishing',
        enabled = true
    },
    {
        id = 'vehicle_registration',
        label = 'Vehicle Registration',
        description = 'Vehicle registration services. More options coming soon.',
        icon = 'file-signature',
        price = 1500,
        metadataKey = 'vehicle_registration',
        enabled = true
    }
}

Config.Jobs = {
    {
        name = 'unemployed',
        grade = 0,
        label = 'Unemployed',
        description = 'No formal employment. Useful if you want to leave your current starter job.',
        salary = 0,
        icon = 'user'
    },
    {
        name = 'garbage',
        grade = 0,
        label = 'Garbage Collector',
        description = 'Collect trash around the city and earn steady pay.',
        salary = 75,
        icon = 'trash'
    },
    {
        name = 'taxi',
        grade = 0,
        label = 'Taxi Driver',
        description = 'Transport citizens around the city.',
        salary = 90,
        icon = 'taxi'
    },
    {
        name = 'bus',
        grade = 0,
        label = 'Bus Driver',
        description = 'Run public routes and keep the city moving.',
        salary = 85,
        icon = 'bus'
    },
    {
        name = 'tow',
        grade = 0,
        label = 'Tow Operator',
        description = 'Tow abandoned or broken vehicles.',
        salary = 95,
        icon = 'truck-pickup'
    },
    {
        name = 'delivery',
        grade = 0,
        label = 'Delivery Driver',
        description = 'Handle legal package delivery work across Los Santos.',
        salary = 80,
        icon = 'box'
    },
    {
        name = 'hotdog',
        grade = 0,
        label = 'Hotdog Vendor',
        description = 'Run food stand work and serve citizens.',
        salary = 70,
        icon = 'utensils'
    }
}

Config.Records = {
    enabled = true,

    entries = {
        {
            label = 'Citizen Profile',
            description = 'Review your personal government profile.',
            icon = 'address-card'
        },
        {
            label = 'License Status',
            description = 'View active and inactive licenses.',
            icon = 'clipboard-check'
        },
        {
            label = 'Employment Record',
            description = 'Review your current employment status.',
            icon = 'briefcase'
        }
    }
}

Config.Text = {
    headerTitle = 'San Andreas City Hall',
    headerSubtitle = 'Government Services Division',
    badgeText = 'Official Civic Portal',
    footerNote = 'All services are logged and processed through city records.'
}