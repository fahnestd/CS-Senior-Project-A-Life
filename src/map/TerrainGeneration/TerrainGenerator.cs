using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.TerrainGeneration
{
    public abstract class TerrainGenerator
    {
        protected int mapWidth, mapHeight;
        protected int tileCount = 0;

        public int[,] GenerateMap(int mapWidth, int mapHeight)
        {
            tileCount = 3;

            this.mapWidth = mapWidth;
            this.mapHeight = mapHeight;

            int[,] tilemap = new int[mapWidth, mapHeight];
            for (int x = 0; x < mapWidth; x++)
            {
                for (int y = 0; y < mapHeight; y++)
                {
                    tilemap[x, y] = GetNoiseValueForCoordinate(x, y);
                }
            }
            return tilemap;
        }
        protected abstract int GetNoiseValueForCoordinate(int x, int y);
    }
}
