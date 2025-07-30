using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DirSynchroniser.Models
{
    internal class SyncConfig
    {
        public required string SourcePath { get; set; }
        public required string TargetPath { get; set; }
        public int IntervalInSeconds { get; set; }
        public required string LogFilePath { get; set; }
    }
}
