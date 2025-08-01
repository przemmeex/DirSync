using NLog;
using System.Security.Cryptography;

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
            this.logger.Debug("sync is starting");

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
                        this.logger.Info($"created directory: {targetDir}");
                    }
                }
                catch (IOException ex)
                {
                    this.logger.Warn($"couldn't create directory: {targetDir}. Error: {ex.Message}");
                }
            }

            var sourceFiles = Directory.GetFiles(sourcePath, "*", SearchOption.AllDirectories);
            var sourceRelativePaths = sourceFiles
                .Select(file => Path.GetRelativePath(sourcePath, file))
                .ToArray();
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
                            string sourceChecksum = ComputeFileChecksum(sourceFile);
                            string targetChecksum = ComputeFileChecksum(existingTargetFile);
                            needsCopy = !string.Equals(sourceChecksum, targetChecksum, StringComparison.OrdinalIgnoreCase);
                        }
                    }

                    if (needsCopy)
                    {
                        using var sourceStream = new FileStream(sourceFile, FileMode.Open, FileAccess.Read, FileShare.Read);
                        using var targetStream = new FileStream(existingTargetFile, FileMode.Create, FileAccess.Write, FileShare.None);
                        sourceStream.CopyTo(targetStream);
                        this.logger.Info($"copied or updated: {existingTargetFile}");
                    }
                }
                catch (IOException ex)
                {
                    this.logger.Warn($"couldn't update: {existingTargetFile}. Error: {ex.Message}");
                }
            }

            foreach (var targetFile in targetRelativePaths)
            {
                if (!sourceRelativePaths.Contains(targetFile))
                {
                    var existingTargetFile = Path.Combine(targetPath, targetFile);
                    try
                    {
                        File.Delete(existingTargetFile);
                        this.logger.Info($"removed redundant: {existingTargetFile}");
                    }
                    catch (IOException ex)
                    {
                        this.logger.Warn($"could not remove: {existingTargetFile} Error: {ex.Message}");
                    }
                }
            }

            var targetDirs = Directory.GetDirectories(targetPath, "*", SearchOption.AllDirectories);
            foreach (var targetDir in targetDirs.OrderByDescending(d => d.Length))
            {
                var relativePath = Path.GetRelativePath(targetPath, targetDir);
                var sourceDir = Path.Combine(sourcePath, relativePath);

                try
                {
                    if (!Directory.Exists(sourceDir))
                    {
                        Directory.Delete(targetDir, true);
                        this.logger.Info($"removed redundant directory: {targetDir}");
                    }
                }
                catch (IOException ex)
                {
                    this.logger.Warn($"could not remove directory: {targetDir}. Error: {ex.Message}");
                }
            }

        }

        private static string ComputeFileChecksum(string filePath)
        {
            using var sha256 = SHA256.Create();
            using var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.Read);
            var hash = sha256.ComputeHash(stream);
            return BitConverter.ToString(hash);
        }
    }
}
