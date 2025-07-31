using DirSynchroniser.Models;
using DirSynchroniser.Services;
using NLog;
using System;
using System.Threading;

namespace DirSynchroniser
{
    class Program
    {
        static void Main(string[] args)
        {
            var logger = LogManager.GetCurrentClassLogger();

            try
            {
                if (args.Length < 4)
                {
                    Console.WriteLine("usage: DirSynchroniser sourcePath targetPath intervalInSeconds logFilePath");
                    return;
                }

                string sourcePath = args[0];
                string targetPath = args[1];
                if (!int.TryParse(args[2], out int intervalSeconds))
                {
                    Console.WriteLine("enter an integer for interval");
                    return;
                }
                string logFilePath = args[3];

                var config = LogManager.Configuration;
                var fileTarget = config?.FindTargetByName<NLog.Targets.FileTarget>("file");
                if (fileTarget != null && logFilePath != null)
                {
                    fileTarget.FileName = Path.Combine(logFilePath, "sync.log");
                    LogManager.ReconfigExistingLoggers();
                }
                logger.Info("Starting directory synchronisation from {0} to {1} every {2} seconds.", sourcePath, targetPath, intervalSeconds);
                var synchroniser = new DirectorySynchroniser(sourcePath, targetPath, logger);
                synchroniser.Synchronise();

                // TBD run synchronisation periodically
            }
            catch (Exception mainException)
            {
                logger.Error(mainException, "Fatal error");
            }
            finally
            {
                LogManager.Shutdown();
            }
        }
    }
}