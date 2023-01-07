local susp = {}
susp.extends = "Spatial"

--settings
susp.damping = export {20}
susp.stiffness = export {10}
--susp.springarmlen = export {2}
susp.debug = export {false}

--------------------------------------------------------------------------------

function susp:_ready() 
self.body = self:get_parent()
self.spring = self:get_node("SpringArm")
--susp.spring.spring_length = susp.springarmlen
--self.wheel = self:get_node("SpringArm/Wheel")
end
--------------------------------------------------------------------------------

oldlen = 0
function susp:_physics_process(delta) 
	--sussy suspension
	if not self.body.sleeping then
		
		--if springarm is hitting
		if self.spring:get_hit_length() < self.spring.spring_length then
			local offset = self.spring.spring_length - self.spring:get_hit_length()
			
			
			--this sucks
			currentlen = self.spring:get_hit_length()
			
			self.springvel = (currentlen - oldlen) / delta
			
			oldlen = self.spring:get_hit_length()
			
			if self.springvel < 0 then
				self.springvel = self.springvel * -1
			end
			
			force = (offset * self.stiffness) / self.spring.spring_length + (self.damping * self.springvel)
			
			force = math.clamp(force, 0, 9999)
			
			if self.debug then
				--print(offset)
				
				--print(springdir)
				--print(self.springvel)
				--print(self.damping * self.springvel)
				--print(force)
				--print(self.spring:get_hit_length())
				--fuck
				--print(self:springvel(delta, self.spring) * self.damping)
			end
			
			self.body:add_force(Vector3.UP * force * delta, self.translation)
		end
	end
end

return susp
