
ENT.Base = "lvs_base_starfighter"

ENT.PrintName = "ARC-170 fighter"
ENT.Author = "Luna"
ENT.Information = "Heavy-Duty Starfighter of the Galactic Republic"
ENT.Category = "[LVS] - Star Wars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/blu/arc170.mdl"
ENT.GibModels = {
	"models/salza/arc170_gib1.mdl",
	"models/salza/arc170_gib2.mdl",
	"models/salza/arc170_gib3.mdl",
	"models/salza/arc170_gib4.mdl",
	"models/salza/arc170_gib5.mdl",
	"models/salza/arc170_gib6.mdl"
}

ENT.AITEAM = 2

ENT.MaxVelocity = 2500
ENT.MaxThrust = 2500

ENT.TurnRatePitch = 1
ENT.TurnRateYaw = 1
ENT.TurnRateRoll = 1

ENT.ForceLinearMultiplier = 1

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.MaxHealth = 800
ENT.MaxShield = 100

function ENT:OnSetupDataTables()
	self:AddDT( "Bool", "Foils" )
end

function ENT:InitWeapons()
	self.FirePositions = {
		Vector(3.97,-56.3,53.79),
		Vector(4.01,56.39,46.96),
		Vector(4.01,-56.39,46.96),
		Vector(3.97,56.3,53.79),
	}

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/mg.png")
	weapon.Ammo = 3000
	weapon.Delay = 0.07
	weapon.HeatRateUp = 0.25
	weapon.HeatRateDown = 1
	weapon.Attack = function( ent )
		ent.NumPrim = ent.NumPrim and ent.NumPrim + 1 or 1
		if ent.NumPrim > #ent.FirePositions then ent.NumPrim = 1 end

		if not ent:GetFoils() then
			ent:SetHeat( ent:GetHeat() + 0.1 )
		end
	
		local pod = ent:GetDriverSeat()

		if not IsValid( pod ) then return end

		local startpos = pod:LocalToWorld( pod:OBBCenter() )
		local trace = util.TraceHull( {
			start = startpos,
			endpos = (startpos + ent:GetForward() * 50000),
			mins = Vector( -10, -10, -10 ),
			maxs = Vector( 10, 10, 10 ),
			filter = ent:GetCrosshairFilterEnts()
		} )

		local CurPos = ent.FirePositions[ent.NumPrim]

		local bullet = {}
		bullet.Src 	= ent:LocalToWorld( CurPos )
		bullet.Dir 	= (trace.HitPos - bullet.Src):GetNormalized()
		bullet.Spread 	= Vector( 0.025,  0.025, 0 )
		bullet.TracerName = "lvs_laser_green"
		bullet.Force	= 10
		bullet.HullSize 	= 25
		bullet.Damage	= 25
		bullet.Velocity = 60000
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
			local effectdata = EffectData()
				effectdata:SetStart( Vector(50,255,50) ) 
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetNormal( tr.HitNormal )
			util.Effect( "lvs_laser_impact", effectdata )
		end
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetStart( Vector(50,255,50) )
		effectdata:SetOrigin( bullet.Src )
		effectdata:SetNormal( ent:GetForward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		ent:TakeAmmo()

		if CurPos.y > 0 then
			ent.SNDLeft:PlayOnce( 100 + math.cos( CurTime() + self:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )
		else
			ent.SNDRight:PlayOnce( 100 + math.cos( CurTime() + self:EntIndex() * 1337 ) * 5 + math.Rand(-1,1), 1 )
		end
	end
	weapon.OnSelect = function( ent )
		ent:EmitSound("physics/metal/weapon_impact_soft3.wav")

		if ent.SetFoils then ent:SetFoils( true ) end
	end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	self:AddWeapon( weapon )
end

ENT.FlyByAdvance = 0.5
ENT.FlyBySound = "lvs/vehicles/vwing/flyby.wav" 
ENT.DeathSound = "lvs/vehicles/generic_starfighter/crash.wav"

ENT.EngineSounds = {
	{
		sound = "lvs/vehicles/vwing/loop.wav",
		sound_int = "lvs/vehicles/vwing/loop_interior.wav",
		Pitch = 80,
		PitchMin = 0,
		PitchMax = 255,
		PitchMul = 40,
		FadeIn = 0,
		FadeOut = 1,
		FadeSpeed = 1.5,
		UseDoppler = true,
	},
}