using Godot;
using SeniorProject.src.map;
using System;

public partial class WaterPressure : TileMap
{

    [Export]
    private int seed = 1000;

    private SimulationMap simMap;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        simMap = GetParent<SimulationMap>();
        InitializeMap(simMap);
    }

    public void InitializeMap(SimulationMap simMap)
    {
        for (int x = 0; x < simMap.GetMapWidth(); x++)
        {
            for (int y = 0; y < simMap.GetMapHeight(); y++)
            {
                SetCell(0, new Vector2I(x, y), 1, SimulationMap.getTileCoordinates((int)simMap.map[x, y].Temperature));
            }
        }
    }
}
