local plr = {}
plr.extends = "RigidBody"

--settings
plr.active = export {true}
plr.maxspeed = export {8}
plr.maxaccel = export {50}
plr.jumpheight = export {2.3}
--------------------------------------------------------------------------------

--initializing stuff
function plr:_ready()
	plr.cam = self:get_node("CameraNode")
	plr.collider = self:get_node("CollisionShape")
	plr.groundarea = self:get_node("Area")
	plr.mesh = self:get_node("MeshInstance")
end
--------------------------------------------------------------------------------

--teleport player but only while inactive
function plr:tele(pos)
	if not self.active then
		self:set_indexed("translation:x", pos.x)
		self:set_indexed("translation:y", pos.y)
		self:set_indexed("translation:z", pos.z)
		print("teleported to", pos)
	else
		print("error, player tried to call tele() while active")
	end
end
--------------------------------------------------------------------------------

--wasd and view direction walk function
function plr:mover(delta, plr)

	--first, create wishdir
	local forward = Input:is_action_pressed("move_forward")
	local backward = Input:is_action_pressed("move_back")

	local right = Input:is_action_pressed("move_right")
	local left = Input:is_action_pressed("move_left")

	local wishdir = Vector3.ZERO

	if forward and not backward then
		wishdir.z = -1 -- -z
	elseif backward and not forward then
		wishdir.z = 1-- +z
	else
		wishdir.z = 0
	end

	if not right and not left then
		wishdir.x = 0
	elseif right then
		wishdir.x = 1 -- +x
	elseif left then
		wishdir.x = -1 -- -x
	end
	
	wishdir = wishdir:normalized()
	
	--rotate wishdir to camera
	wishdir = wishdir:rotated(Vector3.UP, plr.cam.global_rotation.y)
	
	
	--measure speed with dot
	local velocity = wishdir:dot(plr.linear_velocity)
	
	--limit speed
	--addspeed = math.clamp(0, maxspeed - velocity, maxaccel * delta)
	
	--print(math.clamp(0, plr.maxspeed - velocity, plr.maxaccel * delta))
	
	plr:add_central_force(wishdir * 1000 * delta)--+ addspeed * plr.linear_velocity * delta)
end
--------------------------------------------------------------------------------

--simple jump function
local ground = true
function plr:jump(plr)
	local space = Input:is_action_pressed("space")
	
	if #plr.groundarea:get_overlapping_bodies() > 1 then
		ground = true
	else
		ground = false
	end
	
	if space and ground then
		plr:apply_central_impulse(Vector3.UP * plr.jumpheight)
	end
end
--------------------------------------------------------------------------------

local debounce0 = false
function plr:_process(delta)
	self.cam.active = self.active
	
	if self.active then		
		
		--enable collision
		self.collider.disabled = false
		
		--unlock movement
		self:set_indexed("axis_lock_linear_x", false)
		self:set_indexed("axis_lock_linear_y", false)
		self:set_indexed("axis_lock_linear_z", false)
			
		--make visible
		self.mesh.visible = true
		
		--control functions
		self:mover(delta, self)
		self:jump(self)
	else
		--disable collision
		self.collider.disabled = true
		
		--lock movement
		self:set_indexed("axis_lock_linear_x", true)
		self:set_indexed("axis_lock_linear_y", true)
		self:set_indexed("axis_lock_linear_z", true)
		
		--make invisible
		self.mesh.visible = false
	end
end

return plr
