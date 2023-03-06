local susp = {}
susp.extends = "Spatial"

--settings
susp.damping = export {0.5}
susp.stiffness = export {500}
susp.spring_length = export {1}

susp.friction = export {2000}
--at what speed does friction lose effectiveness
susp.max_friction_speed = export {40}
--------------------------------------------------------------------------------

function susp:_ready() 
	self.body = self:get_parent()
	self.ray = self:get_node("RayCast")
	self.wheel = self:get_node("MeshInstance")
	
	self.stiffness = self.stiffness * self.body.mass
	self.damping = self.damping * self.stiffness
	
	self.friction = self.friction * self.body.mass
end
--------------------------------------------------------------------------------
local timer = 0
susp.old_len = 0
susp.prev_pos = susp.global_translation
function susp:_physics_process(delta) 
	if self.body.sleeping then
		return
	end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	--get spring velocity
	self.current_len = self:get_hit_length()
	self.spring_vel = 0
	
	if self.current_len == self.spring_length then
		self.spring_vel = 0
	else
		self.spring_vel = (self.current_len - self.old_len) / delta
	end
	
	self.old_len = self.current_len
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	--getting rotations and translations
	self.vehicle_rotation = self.body.global_transform.basis:get_rotation_quat()
	self.wheel_location = self.vehicle_rotation * self.translation 
	
	self.wheel_location.y = self.wheel_location.y - self:get_hit_length()
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------	
	--getting a velocity vector3 (non physics node needs its own calculations)
	self.linear_velocity = (self.global_translation - self.prev_pos) / delta
	self.prev_pos = self.global_translation
	--self.linear_velocity = self.vehicle_rotation * self.linear_velocity
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	--work out force
	self.offset = self.spring_length - self:get_hit_length()
	
	self.force = (self.offset * self.stiffness) - (self.damping * self.spring_vel)
	self.force = math.max(self.force, 0)
	self.force = self.force * self.ray:get_collision_normal()
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	--friction
	if self.current_len ~= self.spring_length then
		--do the funny
		--self.side_vector = self.vehicle_rotation * self.global_transform.basis:get_axis(0)
		self.side_vector = self.global_transform.basis:get_axis(0)
		self.side_velocity = self.linear_velocity:dot(self.side_vector)
		
		self.side_force = Vector3.ZERO
		
		self.side_force = -self.side_velocity * self.friction * self.side_vector
		
	end
	
--	if self.stiffness > 250 * self.body.mass then
--		print(self.side_velocity)
--	end
	
	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	--finally, adding force
	--self.body:add_force((self.force) * delta, self.wheel_location)
	self.body:add_force((self.force + self.side_force) * delta, self.wheel_location)
	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	--wheel rotation
	local forward_velocity = self.linear_velocity:dot(self.global_transform.basis:get_axis(1))
	self.wheel:rotate_x(forward_velocity * delta / self.shape.radius)
	
end

return susp
