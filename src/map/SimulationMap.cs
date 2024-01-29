using Godot;
using SeniorProject.src.map.TerrainGeneration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SeniorProject.src.map.Tiles;

namespace SeniorProject.src.map
{
    internal class SimulationMap
    {
        [Export]
        private static int mapWidth = 250;
        [Export]
        private static int mapHeight = 250;

        public static SimulationMap instance = new();

        public Tile[,] map = new Tile[mapWidth, mapHeight];

        public void InitializeMap()
        {
            Random rand = new Random();
            int seed = rand.Next();
            TerrainGenerator TerrainGenerator = new CellularGradientTerrainGenerator(seed);
            int[,] TerrainMap = TerrainGenerator.GenerateMap(mapWidth, mapHeight); 
            for (int x = 0; x < mapWidth; x++)
            {
                for (int y = 0; y < mapHeight; y++)
                {
                    map[x, y] = new Tile(TerrainMap[x, y]);
                }
            }

            seed++;
            TerrainGenerator TemperatureGenerator = new InverseCellularGradientTerrainGenerator(seed);
            int[,] TemperatureMap = TemperatureGenerator.GenerateMap(mapWidth, mapHeight);
            for (int x = 0; x < mapWidth; x++)
            {
                for (int y = 0; y < mapHeight; y++)
                {
                    map[x, y].Temperature = TemperatureMap[x, y];
                }
            }
        }

        public static Vector2I getTileCoordinates(int TileValue)
        {
            int TilesetWidth = 2;
            return new Vector2I(TileValue % TilesetWidth, TileValue / TilesetWidth);
        }

    }
}
