local freezer = {}

freezer.timelimit = export {5}
local timer = 0

function freezer:_ready()
	self.body = self:get_parent()
	
	local lock_x = self.body.axis_lock_linear_x
	local lock_y = self.body.axis_lock_linear_y
	local lock_z = self.body.axis_lock_linear_z
	
	if lock_x == nil or lock_y == nil or lock_z == nil then
		print("error; start_freezer is not under a rigidbody")
	end
	
	self.body:set_indexed("axis_lock_linear_x", true)
	self.body:set_indexed("axis_lock_linear_y", true)
	self.body:set_indexed("axis_lock_linear_z", true)
	
end

function freezer:_process(delta)
	if timer < self.timelimit then
		timer = timer + delta
	else
		self.body:set_indexed("axis_lock_linear_x", false)
		self.body:set_indexed("axis_lock_linear_y", false)
		self.body:set_indexed("axis_lock_linear_z", false)
		self:queue_free()
	end
end




return freezer
