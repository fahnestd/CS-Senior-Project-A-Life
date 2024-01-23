using System.Linq;
using GeneticSharp.Domain.Chromosomes;
using GeneticSharp.Domain.Randomizations;

namespace Chromosome.src
{
	public class IntegerChromosome : ChromosomeBase
	{
		private int _minValue;
		private int _maxValue;

		public IntegerChromosome(int length, int minValue, int maxValue)
			: base(length)
		{
			_minValue = minValue;
			_maxValue = maxValue;

			CreateGenes();
		}

		public override Gene GenerateGene(int geneIndex)
		{
			return new Gene(RandomizationProvider.Current.GetInt(_minValue, _maxValue));
		}

		public override IChromosome CreateNew()
		{
			return new IntegerChromosome(Length, _minValue, _maxValue);
		}

		public override string ToString()
		{
			return string.Join(", ", GetGenes().Select(g => g.Value));
		}
	}
}

