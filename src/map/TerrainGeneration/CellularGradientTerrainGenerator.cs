﻿using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.TerrainGeneration
{
    public class CellularGradientTerrainGenerator : ITerrainGenerator
    {

        public FastNoiseLite noise;
        private int tileCount = 0;

        private int mapWidth, mapHeight;

        public CellularGradientTerrainGenerator(int seed, int tileCount)
        {
            noise = new FastNoiseLite();

            noise.Seed = seed;
            noise.NoiseType = FastNoiseLite.NoiseTypeEnum.Cellular;
            noise.Frequency = 0.02f;
            noise.CellularDistanceFunction = FastNoiseLite.CellularDistanceFunctionEnum.EuclideanSquared;
            noise.CellularReturnType = FastNoiseLite.CellularReturnTypeEnum.Distance2Add;
            noise.CellularJitter = 1.0f;
            noise.DomainWarpAmplitude = 1.2f;

            this.tileCount = tileCount;
        }

        public Vector2I[,] GenerateMap(int mapWidth, int mapHeight)
        {
            this.mapWidth = mapWidth;
            this.mapHeight = mapHeight;
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
            int value = Math.Clamp((int)Math.Floor((absNoise * tileCount) + ExponentialDecay(y, mapHeight, 4)), 0, tileCount);
            return new Vector2I(value % 2, value / 2); // 2 will need to be replaced with the tileset width
        }

        private float ExponentialDecay(int y, int max, int tileCount)
        {
            double floorShift = .9;
            double percentage = -(double)Math.Log(floorShift - (double)((float)y / (float)max) * floorShift) * .2;
            Console.WriteLine(percentage);
            return (float)tileCount * (float)(percentage - .2);
        }
    }
}