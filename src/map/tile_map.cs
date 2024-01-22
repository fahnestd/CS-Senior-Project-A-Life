using Godot;
using SeniorProject.src.map;
using SeniorProject.src.map.TerrainGeneration;
using System;

public partial class tile_map : TileMap
{
    [Export]
    private int mapWidth = 250;
    [Export]
    private int mapHeight = 250;

    [Export]
    private int seed = 1000;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        ITerrainGenerator generator = new CellularTerrainGenerator(seed, 3);
        InitializeMap(generator);
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        if (Input.IsActionJustPressed("regen_map"))
        {
            Random rand = new Random();
            CellularTerrainGenerator generator = new CellularTerrainGenerator(rand.Next(), 3);
            generator.noise.Frequency = (float)GetNode<Slider>("freq").Value;
            generator.noise.CellularJitter = (float)GetNode<Slider>("jitter").Value;
            generator.noise.DomainWarpAmplitude = (float)GetNode<Slider>("amp").Value;
            InitializeMap(generator);
        }
    }

    public void InitializeMap(ITerrainGenerator generator)
    {
        Vector2I[,] tileMap = generator.GenerateMap(mapWidth, mapHeight);

        for (int x = 0; x < mapWidth; x++)
        {
            for (int y = 0; y < mapHeight; y++)
            {
                SetCell(0, new Vector2I(x, y), 2, tileMap[x, y]);
            }
        }
    }
}
