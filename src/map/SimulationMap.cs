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
    
    public partial class SimulationMap : Node2D
    {
        [Export]
        private static int mapWidth = 250;
        [Export]
        private static int mapHeight = 250;

        public static int tileSize = 32;

        //public static SimulationMap instance = new();

        public Tile[,] map = new Tile[mapWidth, mapHeight];

        public SimulationMap()
        {
            InitializeMap();
        }

        public void InitializeMap()
        {
            Random rand = new Random();
            int seed = rand.Next();
            TerrainGenerator TerrainGenerator = new CellularGradientTerrainGenerator(seed);
            int[,] TerrainMap = TerrainGenerator.GenerateMap(mapWidth, mapHeight);
            seed++;
            TerrainGenerator TemperatureGenerator = new InverseCellularGradientTerrainGenerator(seed);
            int[,] TemperatureMap = TemperatureGenerator.GenerateMap(mapWidth, mapHeight);
            for (int y = 0; y < mapHeight; y++)
            {
                for (int x = 0; x < mapWidth; x++)
                {
                    map[x, y] = new Tile();
                    map[x, y].TerrainType = TerrainMap[x, y];
                    map[x, y].Temperature = TemperatureMap[x, y];
                }
            }
        }

        public static Vector2I getTileCoordinates(int TileValue)
        {
            int TilesetWidth = 2;
            return new Vector2I(TileValue % TilesetWidth, TileValue / TilesetWidth);
        }

        public double GetTileWaterPressure(Vector2I coordinates)
        {
            return map[coordinates.X, coordinates.Y].WaterPressure;
        }

        public double GetTileLightLevel(Vector2I coordinates)
        {
            return map[coordinates.X, coordinates.Y].LightLevel;
        }

        public double GetTileTemperature(Vector2I coordinates)
        {
            return map[coordinates.X, coordinates.Y].Temperature;
        }

        public double GetTileTerrainType(Vector2I coordinates)
        {
            return map[coordinates.X, coordinates.Y].TerrainType;
        }

        public int GetMapWidth()
        {
            return mapWidth;
        }

        public int GetMapHeight()
        {
            return mapHeight;
        }

        public int GetTileSize()
        {
            return tileSize;
        }

        public Vector2 GetSpawnCoordinates()
        {
            return new Vector2(mapWidth / 2, mapHeight / 2);
        }
    }
}
