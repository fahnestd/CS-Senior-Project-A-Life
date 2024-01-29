using Godot;
using SeniorProject.src.map;
using SeniorProject.src.map.TerrainGeneration;
using System;

public partial class temp_map : TileMap
{
    [Export]
    private int mapWidth = 250;
    [Export]
    private int mapHeight = 250;

    [Export]
    private int seed = 1000;

    private SimulationMap simMap = SimulationMap.instance;


    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        simMap.InitializeMap();
        InitializeMap();
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


    public void InitializeMap()
    {
        for (int x = 0; x < mapWidth; x++)
        {
            for (int y = 0; y < mapHeight; y++)
            {
                SetCell(0, new Vector2I(x, y), 1, SimulationMap.getTileCoordinates((int)simMap.map[x, y].Temperature));
            }
        }
    }
}
