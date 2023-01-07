local car = {}
car.extends = "RigidBody"

car.active = export {false}

function car:_ready() 
	
end

function car:_on_VehicleSeat_pressed()
	self.active = not self.active
	print(self.active)
end

function car:_process() 
	--sussy suspension
	
	
	if self.active then
		--controls
	end
end

return car
