using Godot;
using System.Collections.Generic;
using GeneticSharp.Domain.Chromosomes;
using GeneticSharp.Domain.Crossovers;

namespace IntegerChromosome.src
{
	public partial class Ocean2D : Node2D
	{
		// Called when the node enters the scene tree for the first time.
		public override void _Ready()
		{
			var parent1 = new IntegerChromosome(5, 0, 10); // Length 5, values between 0 and 10
			var parent2 = new IntegerChromosome(5, 0, 10);

			var crossover = new UniformCrossover(); // UniformCrossover uses a mix of genes from both parents
			var offspring = crossover.Cross(new List<IChromosome> { parent1, parent2 });



			GD.Print("Parent 1: " + parent1);
			GD.Print("Parent 2: " + parent2);
			GD.Print("Offspring 1: " + offspring[0]);
			GD.Print("Offspring 2: " + offspring[1]);

        }

		// Called every frame. 'delta' is the elapsed time since the previous frame.
		public override void _Process(double delta)
		{
		}
	}
}