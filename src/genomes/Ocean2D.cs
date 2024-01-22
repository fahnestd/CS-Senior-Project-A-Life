using Godot;
using System.Collections.Generic;
using GeneticSharp.Domain.Chromosomes;
using GeneticSharp.Domain.Crossovers;
using GeneticSharp.Domain.Mutations;
using System.Linq;

namespace Chromosome.src
{
	public partial class Ocean2D : Node2D
	{
		// Called when the node enters the scene tree for the first time.
		public override void _Ready()
		{
			int currentCreatures = 25;

            /// Genome consists of Physical and Behavioral genomes
            /// The physical genome contains 7 different values: Energy Level, Energy Consumption, Energy Efficiency,
            /// Speed, Age, Max Nodes, and Depth Tolerance. All the values go from 0-10 (integer). 
            /// This can be changed easily if needed.
            List<Genome> genomeList = new();

			for (int i = 0; i < currentCreatures; i++)
			{
                genomeList.Add(new Genome());
            }

            /// The Uniform Crossover uses a fixed mixing ratio between two parents. 
            var crossover = new UniformCrossover();

            /// In the partial shuffle mutation operator, we take a sequence S limited by two 
            /// positions i and j randomly chosen, such that i&lt;j. The gene order in this sequence 
            /// will be shuffled. Sequence will be shuffled until it becomes different than the starting order
            var mutation = new PartialShuffleMutation();

            var offspring = crossover.Cross(new List<IChromosome> { genomeList[0].Physical.GetChromosome,
                                                                    genomeList[1].Physical.GetChromosome });
            GD.Print("Child 1 (not mutated): " + offspring[0]);
            GD.Print("Child 2 (not mutated): " + offspring[1]);
            mutation.Mutate(offspring[0], 0.2f);
            mutation.Mutate(offspring[1], 0.2f);

            var childOne = offspring[0];
            var childTwo = offspring[1];
            currentCreatures += 2;

            //Adding first offspring
            var offspringGenome = new Genome();
            offspringGenome.Physical.SetPhysical(childOne.GetGene(0), childOne.GetGene(1), childOne.GetGene(2), childOne.GetGene(3),
                                                 childOne.GetGene(4), childOne.GetGene(5), childOne.GetGene(6));
            genomeList.Add(offspringGenome);

            //Adding second offspring
            offspringGenome = new Genome();
            offspringGenome.Physical.SetPhysical(childTwo.GetGene(0), childTwo.GetGene(1), childTwo.GetGene(2), childTwo.GetGene(3),
                                                 childTwo.GetGene(4), childTwo.GetGene(5), childTwo.GetGene(6));
            genomeList.Add(offspringGenome);

            
			//Mutation happens 20% of the time for Child 1


            GD.Print("Child 1 Physical Genome (Potential Mutation): " + offspring[0]);
            GD.Print("Child 2 Physical Genome (Potential Mutation): " + offspring[1]);

            for (int i = 0; i < currentCreatures; i++)
			{
                GD.Print("Parent " + (i + 1) + " Physical Genome: " + genomeList[i].Physical.GetChromosome);
            }

        }

		// Called every frame. 'delta' is the elapsed time since the previous frame.
		public override void _Process(double delta)
		{
		}
	}
}
