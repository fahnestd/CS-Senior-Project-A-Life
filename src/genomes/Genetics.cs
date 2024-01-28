using Godot;
using System.Collections.Generic;
using GeneticSharp.Domain.Chromosomes;
using GeneticSharp.Domain.Crossovers;
using GeneticSharp.Domain.Mutations;
using System;

namespace Chromosome.src
{
	public partial class Genetics : Node2D
	{
		public IntegerChromosome IChromosomeFromIntArr(int[] arr)
		{
			var return_arr = new IntegerChromosome(arr.Length, 0, 0);

			for (int i = 0; i < arr.Length; i++)
				return_arr.ReplaceGene(i, new Gene(arr[i]));
			return return_arr;
		}

		public int[] IntArrFromIChromosome(IChromosome chr)
		{
			int[] return_arr = {};
			Array.Resize(ref return_arr, chr.Length);
			for (int i = 0; i < chr.Length; i++)
				return_arr[i] = (int)chr.GetGene(i).Value;
			return return_arr;
		}

		public int[] Crossover(int[] arr, int[] arr_2)
		{
			int length = Math.Max(arr.Length, arr_2.Length);
			if (arr.Length < length)
				Array.Resize(ref arr, length);
			if (arr_2.Length < length)
				Array.Resize(ref arr_2, length);
			var crossover = new UniformCrossover();
			var chromosome_1 = IChromosomeFromIntArr(arr);
			var chromosome_2 = IChromosomeFromIntArr(arr_2);

			var offspring = crossover.Cross(new List<IChromosome> { chromosome_1, chromosome_2 });
			return IntArrFromIChromosome(offspring[0]);
		}

		public int[] Mutation(int[] arr)
		{
			var mutation = new PartialShuffleMutation();
			var chromosome = IChromosomeFromIntArr(arr);

			mutation.Mutate(chromosome, 0.5f);
			return IntArrFromIChromosome(chromosome);
		}
	}
}
