using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.Tiles
{
    public partial class Tile : Node
    {

        public double Temperature { get; set; }
        public double LightLevel { get; set; }
        public double WaterPressure { get; set; }

        public double TerrainType {  get; set; }

        public Vector2I Coordinates { get; set; }

        public Tile()
        {
        }

        public Tile(Vector2I Coordinates,double terrainType, double waterPressure, double lightLevel, double temperature)
        {
            this.Coordinates = Coordinates;
            TerrainType = (double)terrainType;
            WaterPressure = waterPressure;
            LightLevel = lightLevel;
            Temperature = temperature;
        }
        
    }
}
