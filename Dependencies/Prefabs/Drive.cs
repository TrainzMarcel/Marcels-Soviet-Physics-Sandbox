using Godot;
using System;

public class Drive : RigidBody
{
	// Declare member variables here
	[Export]
	private bool parked = false;
	
	float wishdirF, wishdirS, wishbrake;
	//wishdirection forward and steer
	
	RigidBody hubL1, hubL2, hubR1, hubR2;
	HingeJoint JL1, JL2, JR1, JR2;
	
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}
	
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		RigidBody WhL1 = GetParent().GetNode<RigidBody>("WheelBodyL1");
		//GD.Print(WhL1.AngularVelocity.Dot(-WhL1.GlobalTransform.basis.x) * 9.549f);//rads to rpm
		RigidBody WhL2 = GetParent().GetNode<RigidBody>("WheelBodyL2");
		RigidBody WhR1 = GetParent().GetNode<RigidBody>("WheelBodyR1");
		RigidBody WhR2 = GetParent().GetNode<RigidBody>("WheelBodyR2");
		
		RigidBody hubL1 = GetParent().GetNode<RigidBody>("HubBodyL1");
		RigidBody hubL2 = GetParent().GetNode<RigidBody>("HubBodyL2");
		RigidBody hubR1 = GetParent().GetNode<RigidBody>("HubBodyR1");
		RigidBody hubR2 = GetParent().GetNode<RigidBody>("HubBodyR2");
		
		HingeJoint JL1 = GetParent().GetNode<HingeJoint>("HingeJointL1");
		HingeJoint JL2 = GetParent().GetNode<HingeJoint>("HingeJointL2");
		HingeJoint JR1 = GetParent().GetNode<HingeJoint>("HingeJointR1");
		HingeJoint JR2 = GetParent().GetNode<HingeJoint>("HingeJointR2");
		
		
		if (parked == false)
		{
			wishdirS = Input.GetAxis("left", "right");
			//GD.Print(wishdirS);
			wishdirF = Input.GetAxis("down", "up");
			
		
		
		torqueandbrake(wishdirF, WhL1, 0f, 200f, delta);
		torqueandbrake(wishdirF, WhL2, 0f, 200f, delta);
		torqueandbrake(wishdirF, WhR1, 0f, 200f, delta);
		torqueandbrake(wishdirF, WhR2, 0f, 200f, delta);
		
		
		
		steer(-wishdirS, hubL1, 0f, 600f, delta);
		steer(-wishdirS, hubR1, 0f, 600f, delta);
		
		this.AngularVelocity = this.AngularVelocity * 0.99999f * delta;
}
		else
		{
			//brake
		}
		
	}
	/*
	public void gearbox()
	{
		
	}*/
	
	public void torqueandbrake(float wishdirF, RigidBody a, float rpm, float torque, float delta)
	{
		a.AddTorque(-a.GlobalTransform.basis.x * torque * wishdirF * delta);
		//GD.Print(torque * wishdirF * delta, "=", torque, "*", wishdirF, "*", delta);
	}

//experimental feature; above a certain ((forward)) speed, orient wheels toward normalized travel direction vector
//
	public void steer(float wishdirS, RigidBody a, float damping, float servoforce, float delta)
	{
		//max steering angle as a vector (45 degrees)
		float max = 0.5f;
		
		//constructing vector from wheel and pretending its in the local space of the mainbody
		float zangle = this.GlobalRotation.y;
		Vector3 wheelvec = a.GlobalTransform.basis.z.Rotated(a.GlobalTransform.basis.y, -zangle);
		
		//calculating the direction of the torque to apply
		float countertorque = wishdirS - wheelvec.x;
		
		//finally, applying torque on the y vector
		a.AddTorque(a.GlobalTransform.basis.y * servoforce * countertorque * delta);
		
		//damping the steering due to oscillation issues
		a.AngularVelocity = a.AngularVelocity * 0.9999f * delta;
	}
}






