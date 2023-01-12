local rotator = {}
rotator.extends = "Spatial"

rotator.anglemult = export {90}
rotator.angleoffset = export {0}
rotator.inverted = export {false}
rotator.axis = export {"y"} --can be set to "x" "y" or "z"
rotator.angle = 0 --goes from 0-1 in normal circumstances

function rotator:_ready()
	self.rotated = self:get_child(0)
	if self.rotated == nil then
		print("error in rotation node")
	end
	if self.inverted then
		self.anglemult = self.anglemult * -1
	end
end

function rotator:update()
	
	local degrees = self.angle * self.anglemult + self.angleoffset
	
	self.rotated:set_indexed("rotation_degrees:"..self.axis, degrees)
end
return rotator
