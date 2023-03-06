local seat = {}
seat.extends = "Spatial"

function seat:_ready()
	self.cam = self:get_node("CameraNode")
	self.plr = self:get_node("/root/top/PlayerController")
end

function seat:_on_VehicleSeat_pressed()
	if self.plr.active ~= self.cam.active then
		
		if not self.plr.active then
			local pos = self.translation
			pos.x = pos.x - 1
			pos.y = pos.y + 1.5
			
			self.plr:tele(self:to_global(pos))
		end
		
		self.plr:set_indexed("active", not self.plr.active)
		self.cam:set_indexed("active", not self.cam.active)
	else
		print("error! attempted to enable player and camera simultaneously")
		print("try exiting the current seat first.")
	end
end


return seat
