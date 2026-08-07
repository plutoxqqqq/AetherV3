local cloneref = cloneref or function(ref: any)
    return ref
end

if isfolder('aetherv3') then
    delfolder('aetherv3')
end

cloneref(game:GetService('StarterGui')):SetCore('SendNotification', {
    Title = 'AetherV3',
    Text = 'Successfully reinstalled AetherV3, Please rejoin the game to take effect',
    Duration = 20
})