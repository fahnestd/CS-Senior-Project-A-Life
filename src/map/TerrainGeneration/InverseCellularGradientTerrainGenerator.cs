using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.TerrainGeneration
{
    public class InverseCellularGradientTerrainGenerator : TerrainGenerator
    {

        public FastNoiseLite noise;

        public InverseCellularGradientTerrainGenerator(int seed)
        {
            noise = new FastNoiseLite();

            noise.Seed = seed;
            noise.NoiseType = FastNoiseLite.NoiseTypeEnum.Cellular;
            noise.Frequency = 0.02f;
            noise.CellularDistanceFunction = FastNoiseLite.CellularDistanceFunctionEnum.EuclideanSquared;
            noise.CellularReturnType = FastNoiseLite.CellularReturnTypeEnum.Distance2Add;
            noise.CellularJitter = 1.0f;
            noise.DomainWarpAmplitude = 1.2f;
        }

        protected override int GetNoiseValueForCoordinate(int x, int y)
        {
            float absNoise = Math.Abs(noise.GetNoise2D(x, y));
            return Math.Clamp((int)Math.Floor((absNoise * tileCount) + ExponentialDecay(y)), 0, tileCount);
        }

        private float ExponentialDecay(int y)
        {
            double floorModifier = 1.2;
            double percentage = -Math.Log(((double)y / (double)mapHeight) + .001) - floorModifier;
            return (float)tileCount * (float)percentage;
        }
    }
}
