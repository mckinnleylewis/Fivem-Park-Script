-- client.lua
-- This client-side script toggles the parking brake with the space bar (control 22)
-- and displays a custom UI notification via NUI.

local isParked = false
local currentVehicle = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            -- Only allow toggling if the player is the driver.
            if GetPedInVehicleSeat(veh, -1) == ped then
                currentVehicle = veh

                if IsControlJustReleased(0, 22) then
                    isParked = not isParked
                    if isParked then
                        FreezeEntityPosition(veh, true)
                        SendNUIMessage({
                            action = "showNotification",
                            text = "Parking brake engaged."
                        })
                    else
                        FreezeEntityPosition(veh, false)
                        SendNUIMessage({
                            action = "showNotification",
                            text = "Parking brake disengaged. Vehicle may roll away slowly."
                        })
                    end
                end
            end
        else
            if currentVehicle and not isParked then
                local speed = GetEntitySpeed(currentVehicle)
                if speed < 1.0 then
                    local forwardVector = GetEntityForwardVector(currentVehicle)
                    local forceMagnitude = 2.0  -- Reduced force for a slower rollaway.
                    ApplyForceToEntity(
                        currentVehicle,
                        1,
                        forwardVector.x * forceMagnitude,
                        forwardVector.y * forceMagnitude,
                        0.0,
                        0.0, 0.0, 0.0,
                        0, false, true, true, false, true
                    )
                end
            end
        end
    end
end)
