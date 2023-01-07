using Godot;
using System;

public class Jeep : VehicleBody
{
	// Declare member variables here
	[Export]
	private bool parked = true;
	private float steeringIntensity = 0.5f;
	private float enginePower = 100f;
	
	//private VehicleBody MyNode;
	
	//private float ws;
	//private float ad;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		if (parked == false)
		{
			if (Input.IsActionPressed("right")) {this.Steering = -steeringIntensity;}
			else if (Input.IsActionPressed("left")) {this.Steering = steeringIntensity;}
			else {this.Steering = 0.0f;}
			
			if (Input.IsActionPressed("up")) {this.EngineForce = enginePower;}
			else if (Input.IsActionPressed("down")) {this.EngineForce = -enginePower;}
			else {this.EngineForce = 0.0f;}
		}
		else
		{
			this.Brake = enginePower;
		}
	}
}
