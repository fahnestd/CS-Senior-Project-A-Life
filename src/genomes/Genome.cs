using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using GeneticSharp.Domain.Chromosomes;

namespace Chromosome.src
{
	public class Genome
	{
		public PhysicalGenome Physical { get; set; }
		public BehavioralGenome Behavioral { get; set; }

		public Genome()
		{
			Physical = new PhysicalGenome(7, 0, 10);
			Behavioral = new BehavioralGenome();
		}
	}

	public class PhysicalGenome
	{
		private IntegerChromosome chromosome;

		public PhysicalGenome(int length, int minValue, int maxValue)
		{
			chromosome = new IntegerChromosome(length, minValue, maxValue);
		}

		public IntegerChromosome GetChromosome
		{
			get { return chromosome; }
		}

		public void SetPhysical(params Gene[] genes)
		{
			EnergyLevel = Convert.ToInt32(genes[0].Value);
			EnergyConsumption = Convert.ToInt32(genes[1].Value);
			EnergyEfficiency = Convert.ToInt32(genes[2].Value);
			Speed = Convert.ToInt32(genes[3].Value);
			Age = Convert.ToInt32(genes[4].Value);
			MaxNodes = Convert.ToInt32(genes[5].Value);
			DepthTolerance = Convert.ToInt32(genes[6].Value);
		}

		public int EnergyLevel 
		{
			get { return (int)chromosome.GetGene(0).Value; }
			set { chromosome.ReplaceGene(0, new Gene(value)); } 
		}
		public int EnergyConsumption
		{
			get { return (int)chromosome.GetGene(1).Value; }
			set { chromosome.ReplaceGene(1, new Gene(value)); }
		}
		public int EnergyEfficiency
		{
			get { return (int)chromosome.GetGene(2).Value; }
			set { chromosome.ReplaceGene(2, new Gene(value)); }
		}
		public int Speed
		{
			get { return (int)chromosome.GetGene(3).Value; }
			set { chromosome.ReplaceGene(3, new Gene(value)); }
		}
		public int Age
		{
			get { return (int)chromosome.GetGene(4).Value; }
			set { chromosome.ReplaceGene(4, new Gene(value)); }
		}
		public int MaxNodes
		{
			get { return (int)chromosome.GetGene(5).Value; }
			set { chromosome.ReplaceGene(5, new Gene(value)); }
		}
		public int DepthTolerance
		{
			get { return (int)chromosome.GetGene(6).Value; }
			set { chromosome.ReplaceGene(6, new Gene(value)); }
		}
	}

	public class BehavioralGenome
	{
		public List<ConditionalMovement> MovementPatterns { get; set; }
		public SensoryAbilities SensePatterns { get; set; }
		public HealthPattern HealthPatterns { get; set; }

		public BehavioralGenome()
		{
			MovementPatterns = new List<ConditionalMovement>();
		}
	}

	public class ConditionalMovement
	{
		// Need to define the properties and methods for conditional movement
	}

	public class SensoryAbilities
	{
		// Need to define the properties for seeing, smelling, hearing, etc.
	}

	public class HealthPattern
	{
		// Need to define the properties related to the creature's health
	}

}
