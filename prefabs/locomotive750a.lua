local loco = {}
loco.extends = "VehicleBody"

loco.active = export {false}
loco.enginestrength = export {1500}
loco.brakestrength = export {2000}
loco.maxbrakeforce = export {1500}

loco.sensitivity = export {30}

loco.reverser = 0 --0 = neutral, 1 = forward, 2 = reverse
loco.throttle = 0
loco.brake = 0

loco.brakeforce = 0

loco.seatdir = 1--for double ended locos

--------------------------------------------------------------------------------

function loco:_ready()
	self.engine = self.enginestrength * self.mass
	self.brakestrength = self.brakestrength * self.mass
	self.maxbrakeforce = self.maxbrakeforce * self.mass
	
	self.ui = self:get_node("Control")
	self.throttleui = self:get_node("Control/throttle")
	self.brakeui = self:get_node("Control/brake")
	self.reverserui = self:get_node("Control/reverser")
	self.speedui = self:get_node("Control/speed")
	
	--front
	self.throttlelever1 = self:get_node("750batteryloco/controls/RotationNode")
	self.brakelever1 = self:get_node("750batteryloco/controls/RotationNode2")
	self.reverserlever1 = self:get_node("750batteryloco/controls/RotationNode3")
	self.speedgauge1 = self:get_node("750batteryloco/controls/controls/RotationNode")
	
	--rear
	self.throttlelever2 = self:get_node("750batteryloco/controls2/RotationNode")
	self.brakelever2 = self:get_node("750batteryloco/controls2/RotationNode2")
	self.reverserlever2 = self:get_node("750batteryloco/controls2/RotationNode3")
	self.speedgauge2 = self:get_node("750batteryloco/controls2/controls/RotationNode")
end
--------------------------------------------------------------------------------

function loco:_on_VehicleSeat_pressed()
	self.active = not self.active
	self.ui.visible = self.active
	self.seatdir = 1
end

function loco:_on_VehicleSeat2_pressed()
	self.active = not self.active
	self.ui.visible = self.active
	self.seatdir = -1
end
--------------------------------------------------------------------------------

function loco:_input(event)
	if not self.active then
		return
	end
	
	--r reverser
	local r = event:is_action_pressed("r")
	
	if r then
		self.reverser = self.reverser + 1
		
		if self.reverser == 2 then
			self.reverser = -1
		end
	end
end
--------------------------------------------------------------------------------

function loco:_physics_process(delta)
	
	--brake
	local vel = self.linear_velocity:dot(-self.transform.basis:get_axis(2))
	
	
	local accel = vel / delta * 0.00001 -- mult by 0.00001 because im dividing by delta which makes huge values
	
	--making acceleration have a minimum value so that the locomotive can stop on inclines
	if vel / delta < 0.0005 then
		accel = -0.0005
	elseif vel / delta > -0.0005 then
		accel = 0.0005
	end
	
	self.brakeforce = (self.brake * self.brakestrength) * -accel
	
	--setting brake force to 0 below a certain speed to prevent jittering
	if vel < 0.03 and vel > -0.03 then
		self.brakeforce = math.clamp(self.brakeforce, -self.maxbrakeforce / 100, self.maxbrakeforce / 100)
	end
	
	self.brakeforce = math.clamp(self.brakeforce, -self.maxbrakeforce, self.maxbrakeforce)
end
--------------------------------------------------------------------------------

function loco:uiupdate()
	self.throttleui.text = "throttle = " .. tostring(math.floor(self.throttle + 0.5))
	self.brakeui.text = "brake = " .. tostring(math.floor(self.brake + 0.5))
	self.speedui.text = "speed = " .. tostring(math.floor(self.linear_velocity:length() * 3.6 + 0.5)) .. "km/h"
	
	if self.reverser * self.seatdir == 1 then
		self.reverserui.text = "reverser = forward"
	elseif self.reverser * self.seatdir == 0 then
		self.reverserui.text = "reverser = neutral"
	else
		self.reverserui.text = "reverser = back"
	end
end

function loco:cabupdate()
	--front cabin
	self.throttlelever1:set_indexed("angle", self.throttle/100)
	self.throttlelever1:update()
	
	self.brakelever1:set_indexed("angle", self.brake/100)
	self.brakelever1:update()
	
	self.reverserlever1:set_indexed("angle", self.reverser)
	self.reverserlever1:update()
	
	self.speedgauge1:set_indexed("angle", self.linear_velocity:length() * 3.6 / 80)
	self.speedgauge1:update()
	
	--rear cabin
	
	self.throttlelever2:set_indexed("angle", self.throttle/100)
	self.throttlelever2:update()
	
	self.brakelever2:set_indexed("angle", self.brake/100)
	self.brakelever2:update()
	
	self.reverserlever2:set_indexed("angle", self.reverser)
	self.reverserlever2:update()
	
	self.speedgauge2:set_indexed("angle", self.linear_velocity:length() * 3.6 / 80)
	self.speedgauge2:update()
	
end

function loco:_process(delta)
	
	
	--constructing force vector
	local locodir = -self.transform.basis:get_axis(2)
	
	--engine
	local engineforce = self.throttle * self.reverser * self.enginestrength
	
	self:add_central_force(locodir * (engineforce + self.brakeforce) * delta)
	
	
	
	
	
	if not self.active then
		return
	end
	
	
	--ws throttle
	--ad brake
	local forward = Input:is_action_pressed("move_forward")
	local backward = Input:is_action_pressed("move_back")
	local right = Input:is_action_pressed("move_right")
	local left = Input:is_action_pressed("move_left")
	
	
	
	if forward and not backward then
		self.throttle = self.throttle + self.sensitivity * delta
		self.throttle = math.clamp(self.throttle, 0, 100)
	elseif backward and not forward then
		self.throttle = self.throttle - self.sensitivity * delta
		self.throttle = math.clamp(self.throttle, 0, 100)
	end
	
	
	if right and not left then
		self.brake = self.brake + self.sensitivity * delta
		self.brake = math.clamp(self.brake, 0, 100)
	elseif left and not right then
		self.brake = self.brake - self.sensitivity * delta
		self.brake = math.clamp(self.brake, 0, 100)
	end
	
	
	self:uiupdate()
	self:cabupdate()
end

return loco
