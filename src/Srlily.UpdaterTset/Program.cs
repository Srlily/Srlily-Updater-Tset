using System.Text.Json;
using Srlily.UpdaterTset.Models;
using Srlily.UpdaterTset.Services;

namespace Srlily.UpdaterTset;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        if (args.Length > 0)
        {
            try
            {
                Console.OutputEncoding = System.Text.Encoding.UTF8;
                Console.InputEncoding = System.Text.Encoding.UTF8;
            }
            catch
            {
                // non-console hosts may reject encoding switch
            }

            return Cli.Run(args);
        }

        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm());
        return 0;
    }
}

internal static class Cli
{
    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        WriteIndented = true,
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    public static int Run(string[] args)
    {
        var cmd = args[0].TrimStart('-').ToLowerInvariant();
        var app = AppInfo.Load();

        switch (cmd)
        {
            case "version":
            case "v":
                Console.WriteLine(app.Version);
                return 0;

            case "info":
            case "i":
                Console.WriteLine(JsonSerializer.Serialize(app, JsonOpts));
                return 0;

            case "manifest":
            case "m":
                Console.WriteLine(JsonSerializer.Serialize(app.Manifest, JsonOpts));
                return 0;

            case "files":
            case "f":
                foreach (var file in FileInventory.Collect(app.BaseDirectory))
                {
                    Console.WriteLine(file);
                }
                return 0;

            case "locale":
                var locale = args.Length > 1 ? args[1] : "zh-CN";
                var text = LocaleService.Load(locale, app.BaseDirectory);
                Console.WriteLine(JsonSerializer.Serialize(text, JsonOpts));
                return 0;

            case "config":
                Console.WriteLine(JsonSerializer.Serialize(ConfigService.Load(app.BaseDirectory), JsonOpts));
                return 0;

            case "help":
            case "?":
                PrintHelp();
                return 0;

            default:
                Console.Error.WriteLine($"Unknown command: {args[0]}");
                PrintHelp();
                return 2;
        }
    }

    private static void PrintHelp()
    {
        Console.WriteLine("""
            Srlily Updater Test — CLI

            Usage:
              Srlily.UpdaterTset.exe [command]

            Commands:
              --version              Print application version
              --info                 Print AppInfo as JSON
              --manifest             Print update-manifest.json as JSON
              --files                List packaged content files
              --locale [culture]     Print locale strings (default zh-CN)
              --config               Print appsettings.json as JSON
              --help                 Show this help

            Without arguments the GUI starts.
            """);
    }
}
