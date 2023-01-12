local cam = {}
cam.extends = "Spatial"

--settings
cam.active = export {true}
cam.hsensitivity = export {0.2}
cam.vsensitivity = export {0.2}
cam.degreelimit = export {80}

cam.lerpweight = export{0.8}

cam.scrollrate = export {1}
cam.maxscroll = export {10}
cam.minscroll = export {2}
--------------------------------------------------------------------------------

local toggle = false
local debounce0 = false
local debounce1 = false
local switch = false
--------------------------------------------------------------------------------

function cam:_ready()
	cam.viewport = self:get_node("/root")
	self.fpcam = self:get_node("Camera")
	self.ray = self:get_node("Camera/RayCast")
	self.springarm = self:get_node("SpringArm")
	self.tpcam = self:get_node("SpringArm/Camera")
	
	if self.active then
		self.fpcam.current = true
		self.ray.enabled = true
	end
	
	cam.screenwidth = OS.window_size.x
	cam.screenheight = OS.window_size.y
	cam.screencenter = Vector2(cam.screenwidth/2, cam.screenheight/2)
end
--------------------------------------------------------------------------------

function cam:scroll()
	--function to scroll the third person camera
	if self.active then
		if Input:is_mouse_button_pressed(4) then
			self.springarm.spring_length = self.springarm.spring_length - self.scrollrate
		end
		if Input:is_mouse_button_pressed(5) then
			self.springarm.spring_length = self.springarm.spring_length + self.scrollrate
		end
		self.springarm.spring_length = math.clamp(self.springarm.spring_length, self.minscroll, self.maxscroll)
	end
end
--------------------------------------------------------------------------------

local switch = false
local debounce0 = false
function cam:camswitcher()
	--function to switch the cameras
	--simple debounce
	if Input:is_action_pressed("tab") and not debounce0 then
		
		debounce0 = true
		if switch then
			--turn on first person
			switch = false
		else
			--turn on third person
			switch = true
		end
		
	elseif not Input:is_action_pressed("tab") and debounce0 then
		debounce0 = false
	end
	
	if switch then
		self.tpcam:make_current()
	else
		self.fpcam:make_current()
	end
end
--------------------------------------------------------------------------------

local debounce1 = false
local toggle = false
function cam:view(cam, event)
	--function to rotate the camera
	--simple debounce
	if Input:is_action_pressed("alt") and not debounce1 then
		debounce1 = true
		
		if toggle then
			toggle = false
		else
			toggle = true
		end
	elseif not Input:is_action_pressed("alt") and debounce1 then
		debounce1 = false
	end
	
	
	if not toggle then
		Input.mouse_mode = 2 --MOUSE_MODE_CAPTURED
		
		--might add this later
		--would need a target rotation and current rotation 
		--local function lerp(pos1, pos2, perc)
		--	return (1-perc)*pos1 + perc*pos2 --linear interpolation
		--end
		
		--dont forget cam.lerpweight exists
		if event.relative ~= nil then
			
			--rotate camera
			cam:set_indexed("rotation_degrees:y", cam.rotation_degrees.y - event.relative.x * cam.hsensitivity)
			cam:set_indexed("rotation_degrees:x", cam.rotation_degrees.x - event.relative.y * cam.vsensitivity)
			
			--to limit cam rotation
			cam:set_indexed("rotation_degrees:x", math.clamp(cam.rotation_degrees.x, -cam.degreelimit, cam.degreelimit))
		end
	else
		Input.mouse_mode = 0 --MOUSE_MODE_VISIBLE
	end
end
--------------------------------------------------------------------------------

function cam:rayfunc()
	--function to let any plri classes emit the pressed signal
	if self.ray:get_collider() ~= Object.null then
		if self.ray:get_collider():has_method("raycast_touching_button") then
			self.ray:get_collider():raycast_touching_button()	
		end
	end
end
--------------------------------------------------------------------------------
function cam:zoom()
	local function lerp(pos1, pos2, perc)
			return (1-perc)*pos1 + perc*pos2 --linear interpolation
	end
	
	local targetfov = 90
	
	if Input:is_action_pressed("right_cl") then
		targetfov = 30
	end
	
	self.fpcam.fov = lerp(targetfov, self.fpcam.fov, 0.9)
end

--------------------------------------------------------------------------------

function cam:_process(delta)
	self.ray.enabled = self.fpcam.current
	if not self.active then
		return
	end
	self:rayfunc()
	self:camswitcher()
	self:zoom()
	--moved to process for active scaling
	self.screenwidth = OS.window_size.x
	self.screenheight = OS.window_size.y
	self.screencenter = Vector2(cam.screenwidth/2, cam.screenheight/2)
	
end
--------------------------------------------------------------------------------

function cam:_input(event)
	if not self.active then
		return
	end
	self:view(self, event)
	self:scroll(event)
end

return cam
