local junction = {}
junction.extends = "Spatial"

junction.setstraight = true

function junction:_ready()
	self.anim = self:get_node("AnimationPlayer")
end

function junction:_on_PlayerInteract_pressed()
	if not self.anim.playing then
		if self.setstraight then
			self.anim:play("750JunctionAnimation")
		else
			self.anim:play_backwards("750JunctionAnimation")
		end
		self.setstraight = not self.setstraight
	end
end

function junction:_on_straightarea_body_entered(body)
	if not self.anim.playing and not self.setstraight then
		self.anim:play_backwards("750JunctionAnimation")
		self.setstraight = true
	end
end

function junction:_on_leftarea_body_entered(body)
	if not self.anim.playing and self.setstraight then
		self.anim:play("750JunctionAnimation")
		self.setstraight = false
	end
end

return junction
