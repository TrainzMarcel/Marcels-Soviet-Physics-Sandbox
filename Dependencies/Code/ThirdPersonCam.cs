using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class ThirdPersonCam : Spatial
{
	//settings
	private float ScreenHeight = 600f;//in pixels
	private float DegreeLimit = 80f;//how many degrees the camera is allowed to rotate vertically
	private float VSensitivity = 1.5f;//how much to divide vertical mouse distance by
	private float HSensitivity = 1f;//how much to divide horizontal mouse distance by
	private float ScrollSensitivity = 0.5f;//smaller value means lower distance
	
	private float MaxScroll = 20f;
	private float MinScroll = 0.5f;
	
	private float FollowSpeed = 10f; //interpolation weight
	
	[Export]
	private NodePath TargetPath;
	
	//initialization
	private float ScrollDistance = 5;
	private Vector2 MousePos;
	private Vector3 CurrentRotation;
	private Vector3 DampedCurrentRotation;
	
	//private Vector3 CamRotation;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	
	}
	
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		//input
		MousePos = GetViewport().GetMousePosition();
		SpringArm SA = GetNode<SpringArm>("SpringArm");
		Camera C = GetChild(0).GetNode<Camera>("Camera");
		
		
		Spatial Target = GetNode<Spatial>(TargetPath);
		
		//calculation
		CurrentRotation.x = -Mathf.Clamp((MousePos.y - ScreenHeight/2) / VSensitivity, -DegreeLimit, DegreeLimit);
		//up down + half of screen height to center mouse
		CurrentRotation.y = -MousePos.x / HSensitivity;//side to side
		
		DampedCurrentRotation = DampedCurrentRotation.LinearInterpolate(CurrentRotation, FollowSpeed * delta);
		
		//output
		SA.RotationDegrees = DampedCurrentRotation;
		SA.Translation = Target.Translation;
		
		
		//CamRotation.y = CurrentRotation.y - DampedCurrentRotation.y;
		//CamRotation.x = CurrentRotation.x - DampedCurrentRotation.x;
		
		
		//C.RotationDegrees = CamRotation;
	}
	
	//scrolling-------------------------------------------------------------
	public override void _Input(InputEvent inputEvent)
	{
		//input
		SpringArm SA = GetNode<SpringArm>("SpringArm");
		
		if (inputEvent is InputEventMouseButton mouseEvent && mouseEvent.Pressed)
		{
			switch ((ButtonList)mouseEvent.ButtonIndex)
			{
				case ButtonList.WheelUp:
					ScrollDistance = Mathf.Clamp(ScrollDistance - ScrollSensitivity, MinScroll, MaxScroll);
					SA.SpringLength = ScrollDistance;
					break;
				case ButtonList.WheelDown:
					ScrollDistance = Mathf.Clamp(ScrollDistance + ScrollSensitivity, MinScroll, MaxScroll);
					SA.SpringLength = ScrollDistance;
					break;
			}
		}
	}
}
