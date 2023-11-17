using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.TerrainGeneration
{
    public interface ITerrainGenerator
    {
        public Vector2I[,] GenerateMap(int mapWidth, int mapHeight);
    }
}
