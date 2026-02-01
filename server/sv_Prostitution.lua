RegisterServerEvent('gjn_prostitution:pay')
AddEventHandler('gjn_prostitution:pay', function(boolean)
    local Name = GetPlayerName(source)
    if (boolean == true) then
        if GetMoney(Config.BlowjobPrice, source) then
            RemoveMoney(Config.BlowjobPrice, source)
            TriggerClientEvent('gjn_prostitution:startBlowjob', source)
            Logs(source, "Player: **" .. Name .. "**, > prostitution - He paid " .. Config.BlowjobPrice .. " (BLOW JOB)")
        else
            TriggerClientEvent("gjn_prostitution:notify", source, "info", "", locale("not_enough_money"))
            TriggerClientEvent('gjn_prostitution:noMoney', source)
        end
    else
        if GetMoney(Config.SexPrice, source) then
            RemoveMoney(Config.SexPrice, source)
            --TriggerClientEvent('gjn_prostitution:startSex', source)
            -- NEW CODE
            -- Usa algo assim:
            local payload = {
            src      = source,
            pedNetId = data.pedNetId,  -- recebido do cliente que tem a NPC
            vehNetId = data.vehNetId,  -- idem
            anim_npc = { dict = 'amb@incar@male@patrol@idle_a', name = 'idle_b' },  -- EXEMPLO NEUTRO
            anim_player = { dict = 'amb@world_human_seat_wall@female@base', name = 'base' }, -- EXEMPLO NEUTRO
            duration = 30000
            }
            TriggerClientEvent('gjn_prostitution:doService', -1, payload)

            Logs(source, "Player: **" .. Name .. "**, > prostitution - He paid " .. Config.SexPrice .. " (SEX)")
        else
            TriggerClientEvent("gjn_prostitution:notify", source, "info", "", locale("not_enough_money"))
            TriggerClientEvent('gjn_prostitution:noMoney', source)
        end
    end
end)

RegisterNetEvent("gjn_prostitution:startService")
AddEventHandler("gjn_prostitution:startService", function(data)
    local src = source
    local service = (data and data.service) or "sex"
    local pedNetId = data and data.pedNetId
    local vehNetId = data and data.vehNetId
    if not pedNetId or not vehNetId then return end

    -- escolhe preço conforme o serviço (usa as tuas Config.* já existentes)
    local price = (service == "bj") and Config.BlowjobPrice or Config.SexPrice

    if GetMoney(price, src) then
        RemoveMoney(price, src)

        -- MAPEIA ANIMAÇÕES AQUI (NEUTRAS POR DEFEITO)
        -- (Eu não posso fornecer anims explícitas; deixa as tuas aqui se quiseres.)
        local anims = {
            bj  = {
                anim_npc    = { dict = "oddjobs@towing", name = "f_blow_job_loop" },
                anim_player = { dict = "oddjobs@towing",          name = "m_blow_job_loop" },
                duration    = 30000
            },
            sex = {
                anim_npc    = { dict = "mini@prostitutes@sexlow_veh", name = "low_car_sex_loop_female" },
                anim_player = { dict = "mini@prostitutes@sexlow_veh", name = "low_car_sex_loop_player" },
                duration    = 30000
            }
        }

        local chosen = anims[service] or anims.sex

        local payload = {
            src        = src,
            pedNetId   = pedNetId,
            vehNetId   = vehNetId,
            anim_npc   = chosen.anim_npc,
            anim_player= chosen.anim_player,
            duration   = chosen.duration
        }

        -- AGORA SIM: TODOS OS CLIENTES RECEBEM E VEEM A AÇÃO
        TriggerClientEvent("gjn_prostitution:doService", -1, payload)
    else
        TriggerClientEvent("gjn_prostitution:notify", src, "info", "", locale("not_enough_money"))
        TriggerClientEvent("gjn_prostitution:noMoney", src)
    end
end)
