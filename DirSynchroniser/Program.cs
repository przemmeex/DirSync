using DirSynchroniser.Models;
using DirSynchroniser.Services;
using NLog;
using System.Runtime.ExceptionServices;

namespace DirSynchroniser
{
    class Program
    {
        static void Main(string[] args)
        {
            var logger = LogManager.GetCurrentClassLogger();

            try
            {
                string? parameterError = null;
                if (args.Length < 4) parameterError = "usage: DirSynchroniser sourcePath targetPath intervalInSeconds logFilePath";
                if (!Directory.Exists(args[0]) || !Directory.Exists(args[1]) || !Directory.Exists(args[3])) parameterError = "entered path(s) is invalid";
                if (!int.TryParse(args[2], out int intervalSeconds)) parameterError = "enter an integer for interval";
                if (parameterError != null)
                {
                    Console.WriteLine(parameterError);
                    return;
                }

                var passedParams = new SyncConfig
                {
                    SourcePath = args[0],
                    TargetPath = args[1],
                    IntervalInSeconds = int.Parse(args[2]),
                    LogFilePath = args[3]
                };
                var config = LogManager.Configuration;
                var fileTarget = config?.FindTargetByName<NLog.Targets.FileTarget>("file");

                if (fileTarget != null)
                {
                    fileTarget.FileName = Path.Combine(passedParams.LogFilePath, "sync.log");
                    LogManager.ReconfigExistingLoggers();
                }
                logger.Info($"Starting directory synchronisation from {passedParams.SourcePath} to {passedParams.TargetPath} every {passedParams.IntervalInSeconds} seconds");
                var synchroniser = new DirectorySynchroniser(passedParams.SourcePath, passedParams.TargetPath, logger);

                while (true)
                {
                    synchroniser.Synchronise();
                    logger.Debug("Synchronization completed");
                    Thread.Sleep(passedParams.IntervalInSeconds * 1000);
                }
            }
            catch (Exception mainException)
            {
                logger.Error(mainException.Message, "Main error");
            }
            finally
            {
                LogManager.Shutdown();
            }
        }
    }
}