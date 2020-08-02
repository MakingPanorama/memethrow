modifier_blue_man = modifier_blue_man or class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	IsAura					= function(self) return false end,
	IsAuraActiveOnDeath		= function(self) return false end,
	GetEffectName			= function(self) return "particles/cp_fire_blue.vpcf" end,
	GetEffectAttachType		= function(self) return PATTACH_ABSORIGIN_FOLLOW end,
	--GetStatusEffectName		= function(self) return "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf" end,
	StatusEffectPriority	= function(self) return 15 end,
})

function modifier_blue_man:OnCreated()
	self:GetCaster():SetRenderColor(255, 255, 255)
end

modifier_green_man = modifier_green_man or class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	IsAura					= function(self) return false end,
	IsAuraActiveOnDeath		= function(self) return false end,
	GetEffectName			= function(self) return "particles/cp_fire_green.vpcf" end,
	GetEffectAttachType		= function(self) return PATTACH_ABSORIGIN_FOLLOW end,
	--GetStatusEffectName		= function(self) return "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf" end,
	StatusEffectPriority	= function(self) return 15 end,
})

function modifier_green_man:OnCreated()
	self:GetCaster():SetRenderColor(255, 255, 255)
end