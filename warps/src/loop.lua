Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1)
            for i = 1, #locations, 1 do
                loc = locations[i]

                -- Draw the main marker
                DrawMarker(
                    loc.marker,
                    loc.pos.x,
                    loc.pos.y,
                    loc.pos.z - 0.75,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    loc.scale,
                    loc.scale,
                    loc.scale,
                    loc.rgba[1],
                    loc.rgba[2],
                    loc.rgba[3],
                    loc.rgba[4],
                    false,
                    true,
                    2,
                    nil,
                    nil,
                    false
                )

                -- Draw the submarker if it exists
                if loc.submarker ~= nil then
                    DrawMarker(
                        loc.submarker.marker,
                        loc.pos.x,
                        loc.pos.y,
                        loc.submarker.posz,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                        loc.scale / 2,
                        loc.scale / 2,
                        loc.scale / 2,
                        loc.rgba[1],
                        loc.rgba[2],
                        loc.rgba[3],
                        loc.rgba[4],
                        false,
                        true,
                        2,
                        nil,
                        nil,
                        false
                    )
                end

                -- Teleport logic removed here
            end
        end
    end
)