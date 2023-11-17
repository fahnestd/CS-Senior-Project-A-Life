using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SeniorProject.src
{
    public class Genome
    {
        public PhysicalGenome Physical { get; set; }
        public BehavioralGenome Behavioral { get; set; }

        public Genome()
        {
            Physical = new PhysicalGenome();
            Behavioral = new BehavioralGenome();
        }
    }

    public class PhysicalGenome
    {
        public float EnergyLevel { get; set; }
        public float EnergyConsumption { get; set; }
        public float EnergyEfficiency { get; set; }
        public float Speed { get; set; }
        public int Age { get; set; }
        public int MaxNodes { get; set; }
        public float DepthTolerance { get; set; }
    }

    public class BehavioralGenome
    {
        public List<ConditionalMovement> MovementPatterns { get; set; }
        public SensoryAbilities SensePatterns { get; set; }
        public HealthPattern HealthPatterns { get; set; }

        public BehavioralGenome()
        {
            MovementPatterns = new List<ConditionalMovement>();
        }
    }

    public class ConditionalMovement
    {
        // Need to define the properties and methods for conditional movement
    }

    public class SensoryAbilities
    {
        // Need to define the properties for seeing, smelling, hearing, etc.
    }

    public class HealthPattern
    {
        // Need to define the properties related to the creature's health
    }
}

