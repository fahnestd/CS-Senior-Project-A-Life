using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.TerrainGeneration
{
    public class ExponentialTerrainGenerator : TerrainGenerator
    {

        public ExponentialTerrainGenerator(int seed)
        {
            
        }

        protected override int GetNoiseValueForCoordinate(int x, int y)
        {
            int range = 3;
            double exponentialFactor = 1.8;
            double exponentialValue = Math.Exp((double)y / mapHeight * exponentialFactor);
            double normalizedValue = exponentialValue / Math.Exp(exponentialFactor) * range;

            return (int)Math.Floor(normalizedValue);
        }
    }
}
