using Godot;
using SeniorProject.src.map;
using System;

public partial class WaterPressureMap : TileMap
{

    [Export]
    private int seed = 1000;

    private SimulationMap simMap;

    [Export]
    private int sourceID = 0;

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
                SetCell(0, new Vector2I(x, y), sourceID, SimulationMap.getTileCoordinates((int)simMap.map[x, y].WaterPressure));
            }
        }
    }
}
