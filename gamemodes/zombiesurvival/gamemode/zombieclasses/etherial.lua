--CLASS.Hidden = true
--CLASS.Disabled = true

CLASS.Name = "Etherial"
CLASS.TranslationName = "class_etherial"
CLASS.Description = "description_etherial"
CLASS.Help = "controls_etherial"

CLASS.Wave = 1 / 2
CLASS.Health = 160
CLASS.SWEP = "weapon_zs_etherial"
CLASS.Model = Model("models/wraith_zsv1.mdl")
CLASS.Speed = 190


CLASS.Points = 30

CLASS.VoicePitch = 0.65

CLASS.PainSounds = {Sound("npc/stalker/stalker_alert1b.wav"), Sound("npc/stalker/stalker_alert12.wav"), Sound("npc/stalker/stalker_alert13.wav")}
CLASS.DeathSounds = {Sound("npc/stalker/stalker_die1.wav"), Sound("npc/stalker/stalker_die2.wav") }

CLASS.NoShadow = false


function CLASS:Move(pl, move)
	if pl:KeyDown(IN_SPEED) then
		pl:SetRenderMode(RENDERMODE_GLOW) mOwner:SetColor(Color(225,225,225,100))
		move:SetMaxSpeed(50)
		move:SetMaxClientSpeed(50)
	end
end


function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsAttacking and wep:IsAttacking() then
		pl.CalcSeqOverride = 10
	elseif velocity:Length2D() > 0.5 then
		pl.CalcSeqOverride = 3
	else
		pl.CalcSeqOverride = 1
	end

	return true
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return true
end

function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	--[[if pl:IsBarricadeGhosting() then
		dmginfo:SetDamage(dmginfo:GetDamage() * 1.5)
	end]]

	-- The Wraith model doesn't have hitboxes.
	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:FixModelAngles(velocity)

	local seq = pl:GetSequence()
	if seq == 10 then
		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end
end

function CLASS:GetAlpha(pl)
	local wep = pl:GetActiveWeapon()
	if not wep.IsAttacking then wep = NULL end

	if wep:IsValid() and wep:IsAttacking() then
		return 0.7
	elseif MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD then
		local eyepos = EyePos()
		return math.Clamp(pl:GetVelocity():Length() - pl:NearestPoint(eyepos):Distance(eyepos) * 0.5, 35, 180) / 255
	else
		local eyepos = EyePos()
		return math.Clamp(pl:GetVelocity():Length() - pl:NearestPoint(eyepos):Distance(eyepos) * 0.5, 0, 180) / 255
	end
end

function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
	if SERVER then
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos())
			effectdata:SetNormal(pl:GetForward())
			effectdata:SetEntity(pl)
		util.Effect("wraithdeath", effectdata, nil, true)
	end		
	pl:SetRenderMode(RENDERMODE_NORMAL) pl:SetColor(Color(225,225,225,225))
	return true
end

if not CLIENT then return end


function CLASS:PrePlayerDraw(pl)

	pl:RemoveAllDecals()
		local alpha = self:GetAlpha(pl)
		if alpha == 0 then return true end

		render.SetBlend(alpha)
		render.SetColorModulation(0.3, 0.3, 0.3)

end

function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
end

CLASS.Icon = "zombiesurvival/classmenu/wraith"

