using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.Tiles
{
    public class Tile
    {
        public string Name { get; }

        public double Temperature { get; set; }
        public double LightLevel { get; set; }
        public double WaterPressure { get; set; }

        public double TerrainType {  get; set; }

        public Tile()
        {
        }

        public Tile(double terrainType, double waterPressure, double lightLevel, double temperature)
        {
            TerrainType = (double)terrainType;
            WaterPressure = waterPressure;
            LightLevel = lightLevel;
            Temperature = temperature;
        }

    }
}
