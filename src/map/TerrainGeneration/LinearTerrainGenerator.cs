using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src.map.TerrainGeneration
{
    public class LinearTerrainGenerator : TerrainGenerator
    {

        public LinearTerrainGenerator(int seed)
        {
            
        }

        protected override int GetNoiseValueForCoordinate(int x, int y)
        {
            int range = 3;
            return (int)Math.Floor((double)y / mapHeight * range);
        }
    }
}
