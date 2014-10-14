--[[
Soraka, the horn-y star
--]]

Callback.Bind("Load", function() OnLoad() end)

function OnLoad()

	Callback.Bind("GameStart", function() OnGameStart() end)

end

function OnGameStart()

	if myHero.charName ~= "Soraka" then return end

	SorakaVars()
	SorakaMenu()

	SorakaCallBacks()

	Game.Chat.Print("<font color='#0E9B71'>Soraka, the horn-y star by DaPipex Loaded!</font>")

end

function SorakaVars()

	TS = TargetSelector(TargetSelector_Mode.LESS_CAST, TargetSelector_DamageType.MAGIC)

	HechizoQ = {velocidad = 1750, rango = 970, radio = 300, demora = 0.25}
	HechizoW = {rango = 450, demora = 0.25}
	HechizoE = {rango = 925, radio = 300, demora = 0.25}
	HechizoR = {demora = 0.25}

	BasicPrediction.EnablePrediction()

	colorRangos = Graphics.RGB(146, 29, 92)
	colorAreaMouse = Graphics.RGB(44, 202, 49)

	if myHero:GetSpellData(12).name:find("summonerdot") then
		castigoSlot = 12
	elseif myHero:GetSpellData(13).name:find("summonerdot") then
		castigoSlot = 13
	end

end

function SorakaMenu()

	Sorakita = MenuConfig("Soraka - Horny Star")
	Sorakita:Icon("fa-ambulance")

	Sorakita:Menu("keys", "Keys")
	Sorakita.keys:Icon("fa-keyboard-o")
	Sorakita.keys:KeyBinding("combo", "Combo", "SPACE")
	Sorakita.keys:KeyBinding("harass", "Harass with E", "C")
	Sorakita.keys:KeyBinding("healLowest", "Heal lowest ally in range", "A")

	Sorakita:Menu("sbtw", "SBTW")
	Sorakita.sbtw:Icon("fa-rocket")
	Sorakita.sbtw:Boolean("useQ", "Use Q", true)
	Sorakita.sbtw:DropDown("qMin", "Min enemies for Q", 1, {"1", "2", "3", "4", "5"})
	Sorakita.sbtw:Boolean("useE", "Use E", true)
	Sorakita.sbtw:DropDown("eMin", "Min enemies for E", 1, {"1", "2", "3", "4", "5"})

	Sorakita:Menu("heal", "Healing")
	Sorakita.heal:Icon("fa-plus-square")
	Sorakita.heal:Boolean("autoHealOthers", "Auto-Heal others if under x% HP", true)
	Sorakita.heal:Slider("autoHealOthersSlider", "Auto-Heal others % HP", 80, 0, 100)

	Sorakita:Menu("ks", "Killsteal")
	Sorakita.ks:Icon("fa-fire")
	Sorakita.ks:Boolean("useE", "Killsteal with E", true)
	Sorakita.ks:Boolean("useIgnite", "Killsteal with Ignite", true)

	Sorakita:Menu("draw", "Drawings")
	Sorakita.draw:Icon("fa-pencil")
	Sorakita.draw:Boolean("drawQ", "Draw Q Range", true)
	Sorakita.draw:Boolean("drawW", "Draw W Range", true)
	Sorakita.draw:Boolean("drawE", "Draw E Range", true)
	Sorakita.draw:Boolean("drawQERadius", "Draw Q/E AOE Radius", true)

end

function SorakaCallBacks()

	Callback.Bind("Draw", function() OnDraw() end)
	Callback.Bind("Tick", function() OnTick() end)

end

function OnTick()

	ComboKey = Sorakita.keys.combo:IsPressed()
	HarassKey = Sorakita.keys.harass:IsPressed()
	HealLowestKey = Sorakita.keys.healLowest:IsPressed()

	if ComboKey then
		Combo()
	end

	if HarassKey then
		Harass()
	end

	if HealLowestKey then
		HealLowestInRange()
	end

	if Sorakita.heal.autoHealOthers:Value() then
		Ambulance()
	end

	Chequeos()
	Killsteal()

end

function Chequeos()

	Target = TS:GetTarget(HechizoQ.rango)

	QLista = (myHero:CanUseSpell(0) == 0)
	WLista = (myHero:CanUseSpell(1) == 0)
	ELista = (myHero:CanUseSpell(2) == 0)
	RLista = (myHero:CanUseSpell(3) == 0)

	castigoListo = (castigoSlot ~= nil and myHero:CanUseSpell(castigoSlot) == 0)

end

function Combo()

	if Target == nil then return end

	if Sorakita.sbtw.useQ:Value() then
		if QLista then
			if TargetValid(Target, HechizoQ.rango) then
				CastQ(Target)
			end
		end
	end

	if Sorakita.sbtw.useE:Value() then
		if ELista then
			if TargetValid(Target, HechizoE.rango) then
				CastE(Target)
			end
		end
	end
end

function Harass()

	if Target == nil then return end

	if ELista then
		if TargetValid(Target, HechizoE.rango) then
			CastE(Target)
		end
	end
end

function OnDraw()

	if Sorakita.draw.drawQ:Value() then
		Graphics.DrawCircle(myHero, HechizoQ.rango, colorRangos)
	end

	if Sorakita.draw.drawW:Value() then
		Graphics.DrawCircle(myHero, HechizoW.rango, colorRangos)
	end

	if Sorakita.draw.drawE:Value() then
		Graphics.DrawCircle(myHero, HechizoE.rango, colorRangos)
	end

	if Sorakita.draw.drawQERadius:Value() then
		Graphics.DrawCircle(mousePos.x, mousePos.y, mousePos.z, 300, colorAreaMouse)
	end

end

function CastQ(Weon)

	local PPos, table, nEnemies = BasicPrediction.GetBestAoEPositionForce(Weon, HechizoQ.rango, HechizoQ.velocidad, HechizoQ.demora, HechizoQ.radio, false, false, myHero)
	if PPos and nEnemies >= Sorakita.sbtw.qMin:Value() then
		myHero:CastSpell(0, PPos.x, PPos.z)
	end
end

function CastE(Weon)

	local PPos, table, nEnemies = BasicPrediction.GetBestAoEPositionForce(Weon, HechizoE.rango, math.huge, HechizoE.demora, HechizoE.radio, false, false, myHero)
	if PPos and nEnemies >= Sorakita.sbtw.eMin:Value() then
		myHero:CastSpell(2, PPos.x, PPos.z)
	end
end

function Ambulance()

	for i = 1, Game.HeroCount() do
		if Game.Hero(i).team ~= TEAM_ENEMY then
			local ally = Game.Hero(i)
			if ally.health <= ((Sorakita.heal.autoHealOthersSlider:Value() / 100) * ally.maxHealth) then
				if myHero:DistanceTo(ally) < HechizoW.rango then
					myHero:CastSpell(1, ally)
				end
			end
		end
	end
end

function HealLowestInRange()

	local healTarget = nil
	for i = 1, Game.HeroCount() do
		if Game.Hero(i).team == myHero.team then
			local ally = Game.Hero(i)
			if not ally.dead and (myHero:DistanceTo(ally) < HechizoW.rango) and (ally ~= myHero) then
				if healTarget == nil then
					healTarget = ally
				elseif (healTarget.health / healTarget.maxHealth) > (ally.health / ally.maxHealth) then
					healTarget = ally
				end
				if healTarget ~= nil then
					myHero:CastSpell(1, healTarget)
				end
			end
		end
	end
end

function Killsteal()

	for i = 1, Game.HeroCount() do
		if Game.Hero(i).team == TEAM_ENEMY then
			local enemy = Game.Hero(i)

			--local qDmg = myHero:CalcMagicDamage(enemy, (40*myHero:GetSpellData(0).level+30+.35*myHero.ap))
			local eDmg = myHero:CalcMagicDamage(enemy, (40*myHero:GetSpellData(2).level+30+.4*myHero.ap))
			local castigoDmg = (50+20*myHero.level)

			if ELista and (enemy.health < eDmg) and TargetValid(enemy, HechizoE.rango) then
				if Sorakita.ks.useE:Value() then
					myHero:CastSpell(2, enemy)
				end
			end

			if castigoListo and (enemy.health < castigoDmg) and TargetValid(enemy, 600) then
				if Sorakita.ks.useIgnite:Value() then
					myHero:CastSpell(castigoSlot, enemy)
				end
			end
		end
	end
end

function TargetValid(unit, range)

	return unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and unit.visible and not unit.dead and (myHero:DistanceTo(unit) < range)

end
