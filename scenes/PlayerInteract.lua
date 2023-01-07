local plri = {}
plri.extends = "Area"
plri.class_name = "PlayerInteract"
plri.pressed = signal()

local debounce = false
local toggle = false
function plri:raycast_touching_button()
	--simple debounce
	
	if Input:is_action_pressed("interact") and not debounce then
		debounce = true
		
		print("button pressed!")
		self:emit_signal("pressed")
	elseif not Input:is_action_pressed("interact") and debounce then
		debounce = false
	end
end

return plri
