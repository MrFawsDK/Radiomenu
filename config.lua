Config = {}

Config.RadioAnimations = {
    {
        label = "Radio Animation 1",
        description = "Radio animation 1",
        dict = "random@arrests",
        anim = "generic_radio_chatter",
        boneIndex = 18905,
        offset = {x = 0.13555, y = 0.04555, z = -0.0120},
        rotation = {x = 130.0, y = -38.0, z = 170.0},
        useProp = true
    },
    {
        label = "Radio Animation 2", 
        description = "Radio animation 2",
        dict = "anim@male@holding_radio",
        anim = "holding_radio_clip",
        boneIndex = 57005,
        offset = {x = 0.1450, y = 0.0230, z = -0.0230},
        rotation = {x = -90.0, y = 0.0, z = -59.9999},
        useProp = true
    },
    {
        label = "Radio Animation 3",
        description = "Radio animation 3",
        dict = "amb@world_human_drinking@coffee@male@base",
        anim = "base",
        boneIndex = 57005,
        offset = {x = 0.15, y = 0.025, z = -0.02},
        rotation = {x = -125.0, y = 195.0, z = 0.0},
        useProp = true
    },
    {
        label = "Radio Animation 4",
        description = "Radio animation 4",
        dict = "cellphone@",
        anim = "cellphone_call_listen_base",
        boneIndex = 28422,
        offset = {x = 0.01, y = -0.01, z = 0.04},
        rotation = {x = 0.0, y = 0.0, z = 0.0},
        useProp = true
    }
}

Config.Performance = {
    propModel = `prop_cs_hand_radio`,
    timeoutMs = 5000
}

Config.Validation = {
    maxAnimationTime = 300000,
    cleanupDelay = 50
}
