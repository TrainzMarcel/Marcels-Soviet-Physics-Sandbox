using Godot;
using System;

public class SpringJoint : Spatial
{
	[Export]
	public bool debug;

	[Export]
	public float stiffness;
	
	[Export]
	public float damping;
	
	[Export]
	public float restlen;
	
	[Export]
	public NodePath apath;
	public RigidBody a;
	
	[Export]
	public NodePath bpath;
	public RigidBody b;
	
	
	private Vector3 fvec;
	private float currentlen;
	private float bvel;
	private float springforce;
	private float dampingforce;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//restlen = this.GlobalTranslation.DistanceTo(b.GlobalTranslation);
		a = GetNode<RigidBody>(apath);
		b = GetNode<RigidBody>(bpath);
	}
	
// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		
		fvec = this.GlobalTranslation.DirectionTo(b.GlobalTranslation);
		currentlen = this.GlobalTranslation.DistanceTo(b.GlobalTranslation);
		bvel = b.LinearVelocity.Dot(fvec) - a.LinearVelocity.Dot(fvec); 
		
		//dampingforce = -damping * bvel;
		
		springforce = -(currentlen - restlen) * -stiffness;
		
		
		fvec = fvec * (springforce);// - dampingforce);
		
		if (debug)
		{
			//GD.Print(bvel);
			GD.Print(fvec, "  \t");
			//GD.Print(dampingforce, "\t", bvel, "\t", springforce, "\t", fvec.Length());
		}
		
		
		//applying forcee
		a.AddForce(fvec * delta, this.Translation);
		b.AddCentralForce(-fvec * delta);
	}
}
