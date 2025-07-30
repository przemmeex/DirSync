using NLog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DirSynchroniser.Services
{
    internal class DirectorySynchroniser
    {
        private readonly string sourcePath;
        private readonly string targetPath;
        private readonly Logger logger;

        public DirectorySynchroniser(string sourcePath, string targetPath, Logger logger)
        {
            this.sourcePath = sourcePath;
            this.targetPath = targetPath;
            this.logger = logger;
        }

        public void Synchronise()
        {
            this.logger.Info("aaaaaaa");
        }
    }
}
