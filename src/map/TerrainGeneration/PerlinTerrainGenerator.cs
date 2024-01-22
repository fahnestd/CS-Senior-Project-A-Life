using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.TerrainGeneration
{
    public class PerlinTerrainGenerator : ITerrainGenerator
    {
        public FastNoiseLite noise;
        private int tileCount = 0;

        public PerlinTerrainGenerator(int seed, int tileCount)
        {
            noise = new FastNoiseLite();

            noise.Seed = seed;
            noise.NoiseType = FastNoiseLite.NoiseTypeEnum.Perlin;
            noise.Frequency = 0.01f;
            noise.CellularDistanceFunction = FastNoiseLite.CellularDistanceFunctionEnum.Euclidean;
            noise.CellularReturnType = FastNoiseLite.CellularReturnTypeEnum.Distance2Add;
            noise.CellularJitter = 1.0f;
            noise.DomainWarpAmplitude = 0.8f;

            this.tileCount = tileCount;
        }

        public Vector2I[,] GenerateMap(int mapWidth, int mapHeight)
        {
            Vector2I[,] tilemap = new Vector2I[mapWidth, mapHeight];
            for (int x = 0; x < mapWidth; x++)
            {
                for (int y = 0; y < mapHeight; y++)
                {
                    tilemap[x, y] = GetNoiseValueForCoordinate(x, y);
                }
            }
            return tilemap;
        }

        private Vector2I GetNoiseValueForCoordinate(int x, int y)
        {
            float absNoise = Math.Abs(noise.GetNoise2D(x, y));
            int value = (int)Math.Floor(absNoise * tileCount);
            return new Vector2I(value % 2, value / 2); // 2 will need to be replaced with the tileset width
        }
    }
}
