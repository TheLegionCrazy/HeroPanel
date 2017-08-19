local HeroPanel = {}

HeroPanel.optionEnable = Menu.AddOption({ "Awareness", "HeroPanel"}, "On/Off", "Enabled/Disabled ?")

HeroPanel.cachedIcons = nil
HeroPanel.heroIconPath = "resource/flash3/images/heroes/"
HeroPanel.font = Renderer.LoadFont("Verdana", 13, Enum.FontWeight.LIGHT)
handlers = {}

function HeroPanel.OnDraw()
    if not Menu.IsEnabled(HeroPanel.optionEnable) then return end

	local myHero = Heroes.GetLocal()
	
	if not myHero then return end
	
	local myTeam = Entity.GetTeamNum(myHero)
	local drawX = 10
	local drawY = 400
	local lineGap = 20
	local wordGap = 10
	local maxWidth = 200
	local rectHeight = lineGap - 1
	local heroIconWidth = math.floor(rectHeight * 160 / 80) -- original image is 128 * 72 (pixels) / оригинальная иконка 128 & 72
        local w, h = Renderer.GetScreenSize()
	local isSameTeamTable = {}
	
	for i = 1, Heroes.Count() do
		local hero = Heroes.Get(i)
		local sameTeam = Entity.GetTeamNum(hero) == myTeam
		local heroName = NPC.GetUnitName(hero)
		
		isSameTeamTable[#isSameTeamTable + 1] = {heroName, hero}
	end
	
	for i, v in ipairs(isSameTeamTable) do
		local heroName = v[1]
		local hero = v[2]
		
		-- get hero icon / получае иконку хейка
		local tmpHeroName = string.gsub(heroName, "npc_dota_hero_", "")
		local imageHandle
		if handlers[tmpHeroName] then
			imageHandle = handlers[tmpHeroName]
		else
			imageHandle = Renderer.LoadImage(HeroPanel.heroIconPath .. tmpHeroName .. ".png")
			handlers[tmpHeroName] = imageHandle
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
		Renderer.DrawImage(imageHandle, drawX, drawY, heroIconWidth, rectHeight)
		
		-- draw hpBAR / хп (полоска)
		Renderer.SetDrawColor(250, 100, 100, 255) -- red / красный
		local rectWidth = math.floor(125 * (Entity.GetHealth(hero) / Entity.GetMaxHealth(hero)))
		Renderer.DrawFilledRect(w / 2 - 630, drawY, rectWidth, 8)
		
		-- draw manaBAR / мана (полоска)
		Renderer.SetDrawColor(41, 151, 255, 255) -- blue / голубой
		local rectWidth = math.floor(125 * (NPC.GetMana(hero) /NPC.GetMaxMana(hero)))
		Renderer.DrawFilledRect(w / 2 - 630, drawY + 11, rectWidth, 8)

		-- write hp / хп (integer)
		Renderer.SetDrawColor(84, 20, 150, 200) -- purple / фиолетовый
		Renderer.DrawText(HeroPanel.font, w / 2 - 496, drawY - 2, Entity.GetHealth(hero) .. " / " .. Entity.GetMaxHealth(hero), 1)
		
		-- write mana / мана (integer)
		Renderer.SetDrawColor(255, 255, 41, 255) -- yellow // желтый
		Renderer.DrawText(HeroPanel.font, w / 2 - 496, drawY + 10, NPC.GetMana(hero) .. " / " .. NPC.GetMaxMana(hero), 1)
		
		drawY = drawY + lineGap + 10
	end
end

return HeroPanel
