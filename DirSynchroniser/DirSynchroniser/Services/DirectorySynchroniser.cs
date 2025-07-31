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
            this.logger.Info("sync is starting");

            var sourceDirs = Directory.GetDirectories(sourcePath, "*", SearchOption.AllDirectories);
            foreach (var sourceDir in sourceDirs)
            {
                var relativePath = Path.GetRelativePath(sourcePath, sourceDir);
                var targetDir = Path.Combine(targetPath, relativePath);

                try
                {
                    if (!Directory.Exists(targetDir))
                    {
                        Directory.CreateDirectory(targetDir);
                        this.logger.Info($"created directory: {relativePath}");
                    }
                }
                catch (IOException ex)
                {
                    this.logger.Warn($"couldn't create directory: {relativePath}. Error: {ex.Message}");
                }
            }

            var sourceFiles = Directory.GetFiles(sourcePath, "*", SearchOption.AllDirectories);
            var targetFiles = Directory.GetFiles(targetPath, "*", SearchOption.AllDirectories);
            var targetRelativePaths = targetFiles
                .Select(file => Path.GetRelativePath(targetPath, file))
                .ToArray();

            foreach (var sourceFile in sourceFiles)
            {
                var relativePath = Path.GetRelativePath(sourcePath, sourceFile);
                var existingTargetFile = Path.Combine(targetPath, relativePath);
                try
                {
                    bool needsCopy = true;
                    if (targetRelativePaths.Contains(relativePath))
                    {
                        
                        var sourceInfo = new FileInfo(sourceFile);
                        var targetInfo = new FileInfo(existingTargetFile);

                        if (sourceInfo.Length == targetInfo.Length)
                        {
                            using var sourceStream = new FileStream(sourceFile, FileMode.Open, FileAccess.Read, FileShare.Read);
                            using var targetStream = new FileStream(existingTargetFile, FileMode.Open, FileAccess.Read, FileShare.Read);

                            needsCopy = !IsStreamOneEqualTwo(sourceStream, targetStream);
                        }
                    }

                    if (needsCopy)
                    {
                        using var sourceStream = new FileStream(sourceFile, FileMode.Open, FileAccess.Read, FileShare.Read);
                        using var targetStream = new FileStream(existingTargetFile, FileMode.Create, FileAccess.Write, FileShare.None);
                        sourceStream.CopyTo(targetStream);
                        this.logger.Info($"updated: {relativePath}");
                    }
                }
                catch (IOException ex)
                {
                    this.logger.Warn($"couldn't update: {relativePath}. Error: {ex.Message}");
                }
            }

            // TBD remove redundant

        }

        private static bool IsStreamOneEqualTwo(Stream stream1, Stream stream2)
        {
            if (stream1.Length != stream2.Length)
                return false;

            const int BYTES_TO_READ = sizeof(Int64);
            byte[] oneChunk = new byte[BYTES_TO_READ];
            byte[] twoChunk = new byte[BYTES_TO_READ];
            int requiredIterations = (int)Math.Ceiling((double)stream1.Length / BYTES_TO_READ);

            for (int i = 0; i < requiredIterations; i++)
            {
                stream1.Read(oneChunk, 0, BYTES_TO_READ);
                stream2.Read(twoChunk, 0, BYTES_TO_READ);

                if (BitConverter.ToInt64(oneChunk, 0) != BitConverter.ToInt64(twoChunk, 0))
                    return false;
            }


            return true;
        }
    }
}
