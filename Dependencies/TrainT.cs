using Godot;
using System;

public class TrainT : VehicleBody
{
	// Declare member variables here
	[Export]
	private bool parked = false;
	private float enginePower = 30f;
	

	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		if (parked == false)
		{
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
