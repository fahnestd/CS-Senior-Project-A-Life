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
    private int seed = 1001;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        ITerrainGenerator generator = new CellularTerrainGenerator(seed, 4);
        InitializeMap(generator);
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
    }


    public void InitializeMap(ITerrainGenerator generator)
    {
        Vector2I[,] tileMap = generator.GenerateMap(mapWidth, mapHeight);

        for (int x = 0; x < mapWidth; x++)
        {
            for (int y = 0; y < mapHeight; y++)
            {
                SetCell(0, new Vector2I(x, y), 1, tileMap[x, y]);
            }
        }
    }
}
