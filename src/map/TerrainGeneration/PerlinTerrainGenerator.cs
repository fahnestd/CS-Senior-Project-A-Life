using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.TerrainGeneration
{
    public class PerlinTerrainGenerator : TerrainGenerator
    {
        public FastNoiseLite noise;

        public PerlinTerrainGenerator(int seed)
        {
            noise = new FastNoiseLite();

            noise.Seed = seed;
            noise.NoiseType = FastNoiseLite.NoiseTypeEnum.Perlin;
            noise.Frequency = 0.01f;
            noise.CellularDistanceFunction = FastNoiseLite.CellularDistanceFunctionEnum.Euclidean;
            noise.CellularReturnType = FastNoiseLite.CellularReturnTypeEnum.Distance2Add;
            noise.CellularJitter = 1.0f;
            noise.DomainWarpAmplitude = 0.8f;
        }

        protected override int GetNoiseValueForCoordinate(int x, int y)
        {
            float absNoise = Math.Abs(noise.GetNoise2D(x, y));
            return (int)Math.Floor(absNoise * tileCount);
        }
    }
}
