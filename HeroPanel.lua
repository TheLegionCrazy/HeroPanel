local HeroPanel = {}

HeroPanel.optionEnable = Menu.AddOption({ "Awareness", "HeroPanel" }, "On/Off", "Enabled/Disabled ?")
HeroPanel.yPosition = Menu.AddOption({ "Awareness", "HeroPanel", "Panel Position" }, "Y position", "Height in the screen", 0, 800, 25)
HeroPanel.fPosition = Menu.AddOption({ "Awareness", "HeroPanel", "Panel Position" }, "F position", "Hero icon position", Renderer.GetScreenSize(), Renderer.GetScreenSize() * 5, Renderer.GetScreenSize() / 20)
HeroPanel.useDefaultYPos = Menu.AddOption({ "Awareness", "HeroPanel", "Panel Position" }, "Use default Hero position ?", "On/Off")
HeroPanel.showUltimateStatus = Menu.AddOption({ "Awareness", "HeroPanel", "Additionally" }, "Show ultimate status (enemy and teammetes) ?", "On/Off")

HeroPanel.cachedIcons = nil
HeroPanel.heroIconPath = "resource/flash3/images/heroes/"
HeroPanel.font = Renderer.LoadFont("Verdana", 13, Enum.FontWeight.LIGHT)
handlers = {}

function HeroPanel.OnDraw()
    if not Menu.IsEnabled(HeroPanel.optionEnable) then return end

    local myHero = Heroes.GetLocal()

    if not myHero then return end

    local drawX = Menu.GetValue(HeroPanel.fPosition) / 9.6
    local drawY = Menu.GetValue(HeroPanel.yPosition)
    local lineGap = 20
    local rectHeight = lineGap - 1
    local heroIconWidth = math.floor(rectHeight * 160 / 80) -- original image is 128 * 72 (pixels) / оригинальная иконка 128 & 72
    local isSameTeamTable = {}
    local w = Menu.GetValue(HeroPanel.fPosition)

    if Menu.IsEnabled(HeroPanel.useDefaultYPos) then
        drawX = 10
        drawY = 400
    end

    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        local heroName = NPC.GetUnitName(hero)

        isSameTeamTable[#isSameTeamTable + 1] = { heroName, hero }
    end

    for _, v in ipairs(isSameTeamTable) do
        local heroName = v[1]
        local hero = v[2]

        if not NPC.IsIllusion(hero) then
            -- get hero icon / получае иконку хейка
            local tmpHeroName = string.gsub(heroName, "npc_dota_hero_", "")
            local imageHandle
            if handlers[tmpHeroName] then
                imageHandle = handlers[tmpHeroName]
            else
                imageHandle = Renderer.LoadImage(HeroPanel.heroIconPath .. tmpHeroName .. ".png")
                handlers[tmpHeroName] = imageHandle
            end

            local ulimateAbility
            ulimateAbility = NPC.GetAbilityByIndex(hero, 3)

            if ulimateAbility == nil or not Ability.IsUltimate(ulimateAbility) then
                ulimateAbility = NPC.GetAbilityByIndex(hero, 4)
            end

            if ulimateAbility == nil or not Ability.IsUltimate(ulimateAbility) then
                ulimateAbility = NPC.GetAbilityByIndex(hero, 5)
            end

            if ulimateAbility == nil or not Ability.IsUltimate(ulimateAbility) then
                ulimateAbility = NPC.GetAbilityByIndex(hero, 6)
            end

            -- draw borders / задний фон для иконок
            if Entity.GetHealth(hero) == 0 then
                Renderer.SetDrawColor(250, 100, 100, 255) -- red, if hero is dead / красный, если герой умер
                Renderer.DrawFilledRect(1, drawY - 5, heroIconWidth + 150, 28)
            else
                Renderer.SetDrawColor(10, 18, 31, 150) -- gray / серый
                Renderer.DrawFilledRect(1, drawY - 5, heroIconWidth + 150, 28)
            end

            -- draw heroes / иконки героев
            Renderer.SetDrawColor(255, 255, 255, 255) -- white / белый
            if not Menu.IsEnabled(HeroPanel.useDefaultYPos) then
                Renderer.DrawImage(imageHandle, drawX + Renderer.GetScreenSize() / 2, drawY, heroIconWidth, rectHeight)
            else
                Renderer.DrawImage(imageHandle, drawX, drawY, heroIconWidth, rectHeight)
            end

            ready = false

            if Ability.IsCastable(ulimateAbility, NPC.GetMana(hero), false) then
                ready = true
            end

            -- draw hpBAR / хп (полоска)
            if Ability.IsCastable(ulimateAbility, NPC.GetMana(hero), false) or Ability.GetLevel(ulimateAbility) >= 1 then
                Renderer.SetDrawColor(250, 100, 100, 255) -- red / красный
            else
                Renderer.SetDrawColor(250, 255, 255, 255) -- white / белый
            end
            if not Menu.IsEnabled(HeroPanel.showUltimateStatus) then
                Renderer.SetDrawColor(250, 100, 100, 255) -- red / красный
            end

            local rectWidth = math.floor(125 * (Entity.GetHealth(hero) / Entity.GetMaxHealth(hero)))
            Renderer.DrawFilledRect(w / 2 - 630, drawY, rectWidth, 8)

            -- draw manaBAR / мана (полоска)
            Renderer.SetDrawColor(41, 151, 255, 255) -- blue / голубой
            local rectWidth = math.floor(125 * (NPC.GetMana(hero) / NPC.GetMaxMana(hero)))
            Renderer.DrawFilledRect(w / 2 - 630, drawY + 11, rectWidth, 8)

            -- draw ultimateBar / полоска готовности ултимейта
            Renderer.SetDrawColor(150, 50, 100, 255)
            local rectWidth = math.floor(125 * (5 / Ability.GetCooldownTimeLeft(ulimateAbility)))
            if rectWidth > 1 or rectHeight == 1 then
                Renderer.DrawFilledRect(w / 2 - 630, drawY + 22, 1, 8)
            else
                Renderer.DrawFilledRect(w / 2 - 630, drawY + 22, rectWidth, 8)
            end

            -- write hp / хп (integer)
            Renderer.SetDrawColor(84, 120, 150, 200) -- purple / фиолетовый
            if Menu.IsEnabled(HeroPanel.showUltimateStatus) then
                abilityName = string.gsub(Ability.GetName(ulimateAbility), string.gsub(heroName, "npc_dota_hero_", ""), "")
                if ready then
                    Renderer.DrawText(HeroPanel.font, w / 2 - 496, drawY - 2, Entity.GetHealth(hero) .. " / " .. Entity.GetMaxHealth(hero) .. " beware " .. string.gsub(heroName, "npc_dota_hero_", "") .. "'s" .. string.gsub(abilityName, "_", " ") .. "!!!", 1)
                else
                    if Ability.GetManaCost(ulimateAbility) <= NPC.GetMana(hero) then
                        if Ability.GetLevel(ulimateAbility) >= 1 then
                            Renderer.DrawText(HeroPanel.font, w / 2 - 496, drawY - 2, Entity.GetHealth(hero) .. " / " .. Entity.GetMaxHealth(hero) .. "  " .. string.gsub(heroName, "npc_dota_hero_", "") .. "'s" .. string.gsub(abilityName, "_", " ") .. " is on cooldown. Reaming: " .. Ability.GetCooldownTimeLeft(ulimateAbility), 1)
                        else
                            Renderer.DrawText(HeroPanel.font, w / 2 - 496, drawY - 2, Entity.GetHealth(hero) .. " / " .. Entity.GetMaxHealth(hero) .. "  " .. string.gsub(heroName, "npc_dota_hero_", "") .. "'s" .. string.gsub(abilityName, "_", " ") .. " not learned. Wait when he learn it!")
                        end
                    else
                        Renderer.DrawText(HeroPanel.font, w / 2 - 496, drawY - 2, Entity.GetHealth(hero) .. " / " .. Entity.GetMaxHealth(hero) .. "  " .. string.gsub(heroName, "npc_dota_hero_", "") .. "'s" .. string.gsub(abilityName, "_", " ") .. ".No mana. Reaming: " .. Ability.GetManaCost(ulimateAbility) - NPC.GetMana(hero) .. ". is on cooldown. Reaming: " .. Ability.GetCooldownTimeLeft(ulimateAbility), 1)
                    end
                end
            else
                Renderer.DrawText(HeroPanel.font, w / 2 - 496, drawY - 2, Entity.GetHealth(hero) .. " / " .. Entity.GetMaxHealth(hero), 1)
            end

            -- write mana / мана (integer)
            Renderer.SetDrawColor(255, 255, 41, 255) -- yellow // желтый
            Renderer.DrawText(HeroPanel.font, w / 2 - 496, drawY + 10, NPC.GetMana(hero) .. " / " .. NPC.GetMaxMana(hero), 1)

            drawY = drawY + lineGap + 15
        end
    end
end

return HeroPanel
