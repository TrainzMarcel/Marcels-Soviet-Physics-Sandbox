local car = {}
car.extends = "RigidBody"

car.active = export {false}

car.angle = 15
car.power = 5

function car:_ready() 
	self.power = self.power * self.mass
	
	
	self.l1 = self:get_node("WheelL1")
	self.r1 = self:get_node("WheelR1")
end

function car:_on_VehicleSeat_pressed()
	self.active = not self.active
end

function car:_process() 
	if not self.active then
		return
	end
	
	if Input:is_action_pressed("move_forward") then
		self:add_central_force(-self.transform.basis:get_axis(2)*self.power)
	end
	
	if Input:is_action_pressed("move_back") then
		self:add_central_force(self.transform.basis:get_axis(2)* self.power)
	end
	
	local right = Input:is_action_pressed("move_right")
	local left = Input:is_action_pressed("move_left")
	
	if right and not left then
		self.l1:set_indexed("rotation_degrees:y", -self.angle)
		self.r1:set_indexed("rotation_degrees:y", -self.angle)
	elseif left and not right then
		self.l1:set_indexed("rotation_degrees:y", self.angle)
		self.r1:set_indexed("rotation_degrees:y", self.angle)
	else
		self.l1:set_indexed("rotation_degrees:y", 0)
		self.r1:set_indexed("rotation_degrees:y", 0)
	end
end

return car
