local loco = {}
loco.extends = "VehicleBody"
loco.active = export {false}
loco.engine = export {3000}


function loco:_ready()
	
end

function loco:_on_VehicleSeat_pressed()
	self.active = not self.active
end

function loco:_process(delta)
	if self.active then
		--ws throttle
		--r reverser
		--ad brake
		--first, create wishdir
		local forward = Input:is_action_pressed("move_forward")
		local backward = Input:is_action_pressed("move_back")
		
		locodir = -self.transform.basis:get_axis(2)
		
		if forward and not backward then
			self:add_central_force(locodir * self.engine * delta)
		elseif backward and not forward then
			self:add_central_force(-locodir * self.engine * delta)
		else
			--self:add_central_force(locodir * self.engine * delta)
		end
		
		
		
		
	end
end

return loco
