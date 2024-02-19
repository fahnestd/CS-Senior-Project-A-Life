using Godot;
using System;

public partial class CreatureHealth : Node2D
{
    [Export]
    int health = 1000;

    public override void _Ready()
    {
        
    }

    public void SetMaxHealth(int maxHealth)
    {
        health = maxHealth;
    }

    public void Damage(int damage)
    {
        health -= damage;
        if (health <= 0) {
            GetParent().QueueFree();
        }
    }
}
