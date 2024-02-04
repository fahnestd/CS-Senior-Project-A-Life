using Godot;
using SeniorProject.src.map;
using SeniorProject.src.map.TerrainGeneration;
using System;

public partial class temp_map : TileMap
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

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        if (Input.IsActionJustPressed("toggle_tempmap"))
        {
            if (this.IsVisibleInTree())
            {
                this.Hide();
            } else
            {
                this.Show();
            }
        }

        if (Input.IsActionJustPressed("regen_map"))
        {
           
            //TerrainGenerator generator = new InverseCellularGradientTerrainGenerator(rand.Next());
            //InitializeMap(generator);
        }
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
