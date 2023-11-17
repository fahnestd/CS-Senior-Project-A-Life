using Godot;
using SeniorProject.src.map;
using System;

public partial class tile_map : TileMap
{
    [Export]
    private int mapWidth = 250;
    [Export]
    private int mapHeight = 250;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		ITerrainGenerator generator = new CellularTerrainGenerator();
		InitializeMap(generator);
    }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
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
