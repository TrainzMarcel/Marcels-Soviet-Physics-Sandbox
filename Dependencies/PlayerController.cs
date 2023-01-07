using Godot;
using System;

public class PlayerController : KinematicBody
{
	//settings
	[Export]
	private float maxspeed = 8f;
	[Export]
	private float maxaccel = 50f;

	[Export]
	private float forwardspeed = 1f;
	[Export]
	private float sidespeed = 1f;

	[Export]
	private float airfriction = 0.999f;
	[Export]
	private float floorfriction = 0.85f;

	[Export]
	private float jumpheight = 8f;
	[Export]
	private float gravity = 25f;

	[Export]
	private float hsensitivity = 1.5f;//how much to divide horizontal mouse distance by
	[Export]
	private float vsensitivity = 1.5f;//how much to divide vertical mouse distance by

	private float screenheight = 600f;//in pixels
	private float screenwidth = 1024f;
	private float degreelimit = 80f;//how many degrees the camera is allowed to rotate vertically


	//camrotation
	Camera cam;

	//movement stuff
	private Vector2 mousepos;

	private float forwardvec, sidevec;
	private Vector3 wishdir;//normalized sum of above vectors

	private float movez0, movex0, movez1, movex1;

	private float friction;

	private float addspeed, currentspeed;
	private Vector3 vel;

	private float fallspeed;


	//directional
	private Vector3 currentrot;
	private float currentrotrad;

	//alt view toggle stuff
	private bool toggle, debounce;

	//jumpies
	private float up;


	//seat stuff
	private bool seatedval;




	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		cam = GetNode<Camera>("Camera");
		seatedval = false;
		toggle = false;
		debounce = false;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		//camrotation-----------------------------------------------------------
		mousepos = GetViewport().GetMousePosition();
		//mousepos = mousepos.LinearInterpolate(mousepos, 0.5f);

		//alt view toggle stuff
		if (Input.IsActionPressed("alt") && debounce == false)
		{
			debounce = true;
			if (toggle == true)
			{toggle = false;}
			else
			{toggle = true;}
		}
		if (!Input.IsActionPressed("alt") && debounce == true)
		{debounce = false;}

		if (toggle == false)
		{
			GetViewport().WarpMouse (new Vector2(screenwidth / 2, screenheight / 2));

			currentrot.x += - (mousepos.y - screenheight/2) / vsensitivity;
			//up down + half of screen height to center mouse
			currentrot.y += - (mousepos.x - screenwidth / 2) / hsensitivity;//side to side

			currentrot.x = Mathf.Clamp(currentrot.x, -degreelimit, degreelimit);
		}
		cam.RotationDegrees = currentrot;

		//constructing wishdir--------------------------------------------------

		//z
		if (Input.IsActionPressed("up"))
		{forwardvec = -1;}
		else if (Input.IsActionPressed("down"))
		{forwardvec = 1;}
		else
		{forwardvec = 0;}

		//x
		if (Input.IsActionPressed("right"))
		{sidevec = 1;}
		else if (Input.IsActionPressed("left"))
		{sidevec = -1;}
		else
		{sidevec = 0;}



		//apply y rotation to move vector by multiplying x and z vectors with cos and sin values
		currentrotrad = Mathf.Deg2Rad(currentrot.y);

		movez0 = forwardvec * Mathf.Cos(currentrotrad);//z for w and s
		movex0 = forwardvec * Mathf.Sin(currentrotrad);//x for w and s

		movez1 = -sidevec * Mathf.Sin(currentrotrad);//z for a and d
		movex1 = sidevec * Mathf.Cos(currentrotrad);//x for a and d

							// x (side)                 z (forward)
		wishdir = new Vector3((movex1 + movex0) * sidespeed, 0, (movez0 + movez1) * forwardspeed);
		wishdir = wishdir.Normalized();

		//debug-----------------------------------------------------------------
		//GD.Print(wishdir);
		//GD.Print((delta * vel * friction));//vel);
		GD.Print(vel.Length());
		//GD.Print(vel);

		//movement--------------------------------------------------------------
		//calculate velocity
		currentspeed = wishdir.Dot(vel);

		//accelerate
		addspeed = Mathf.Clamp(maxspeed - currentspeed, 0, maxaccel * delta);

		//how do i make friction work
		if (IsOnFloor() == true)		{friction = floorfriction;}
		else if(IsOnFloor() == false)	{friction = airfriction;}

		vel.x = vel.x * friction;
		vel.z = vel.z * friction;

		//calculating velocity
		vel.x = (vel.x + addspeed * wishdir.x);
		vel.z = (vel.z + addspeed * wishdir.z);
		//add gravity

		if (IsOnFloor() == false)
		{vel.y = vel.y - gravity * delta;}
		else if (Input.IsActionPressed("jump") && IsOnFloor() == true)
		{vel.y = jumpheight;}
		else if (!Input.IsActionPressed("jump") || IsOnFloor() == false)
		{vel.y = 0;}



		//finally applying velocity to the kinematicbody
		//movement direction, up direction
		MoveAndSlide(vel, new Vector3( 0, 1, 0 ));
	}
}
