using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Srlily.UpdaterTset.Models;

public sealed class AppInfo
{
    public string AppId { get; init; } = "srlily-updater-tset";
    public string Name { get; init; } = "Srlily Updater Test";
    public string Version { get; init; } = "0.0.0";
    public string FileVersion { get; init; } = "0.0.0.0";
    public string InformationalVersion { get; init; } = "0.0.0";
    public string Runtime { get; init; } = "unknown";
    public string Framework { get; init; } = "unknown";
    public string OsDescription { get; init; } = "unknown";
    public string ProcessArchitecture { get; init; } = "unknown";
    public string BaseDirectory { get; init; } = AppContext.BaseDirectory;
    public DateTimeOffset StartedAt { get; init; } = DateTimeOffset.Now;
    public UpdateManifest? Manifest { get; init; }

    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
    };

    public static AppInfo Load(string? baseDirectory = null)
    {
        var baseDir = baseDirectory ?? AppContext.BaseDirectory;
        var asm = Assembly.GetExecutingAssembly();

        var version = asm.GetName().Version?.ToString(3) ?? "0.0.0";
        var fileVersion = asm.GetCustomAttribute<AssemblyFileVersionAttribute>()?.Version ?? version;
        var infoVersion = asm.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? version;

        return new AppInfo
        {
            Version = version,
            FileVersion = fileVersion,
            InformationalVersion = infoVersion,
            Runtime = System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription,
            Framework = "net10.0-windows",
            OsDescription = System.Runtime.InteropServices.RuntimeInformation.OSDescription,
            ProcessArchitecture = System.Runtime.InteropServices.RuntimeInformation.ProcessArchitecture.ToString(),
            BaseDirectory = baseDir,
            Manifest = UpdateManifest.TryLoad(baseDir)
        };
    }

    public static JsonSerializerOptions SerializerOptions => JsonOpts;
}

public sealed class UpdateManifest
{
    public int SchemaVersion { get; init; } = 1;
    public string AppId { get; init; } = "";
    public string Name { get; init; } = "";
    public string Description { get; init; } = "";
    public string Channel { get; init; } = "stable";
    public string Version { get; init; } = "0.0.0";
    public string Runtime { get; init; } = "";
    public string Homepage { get; init; } = "";
    public ReleaseInfo? Releases { get; init; }
    public EntryInfo? Entry { get; init; }
    public ChecksumInfo? Checksum { get; init; }
    public PathInfo? Paths { get; init; }
    public UpdatePolicyInfo? UpdatePolicy { get; init; }

    public static UpdateManifest? TryLoad(string baseDirectory)
    {
        var path = Path.Combine(baseDirectory, "update-manifest.json");
        if (!File.Exists(path))
        {
            return null;
        }

        try
        {
            var json = File.ReadAllText(path);
            return JsonSerializer.Deserialize<UpdateManifest>(json, AppInfo.SerializerOptions);
        }
        catch
        {
            return null;
        }
    }
}

public sealed class ReleaseInfo
{
    public string Api { get; init; } = "";
    public string DownloadPattern { get; init; } = "";
    public string AssetName { get; init; } = "";
    public string DefaultRid { get; init; } = "win-x64";
    public Dictionary<string, ArchitectureAssets>? Architectures { get; init; }
}

public sealed class ArchitectureAssets
{
    public string Rid { get; init; } = "";
    public string Portable { get; init; } = "";
    public string Setup { get; init; } = "";
    public string Msi { get; init; } = "";
}

public sealed class EntryInfo
{
    public string Executable { get; init; } = "";
    public string[] CliArgs { get; init; } = [];
}

public sealed class ChecksumInfo
{
    public string Algorithm { get; init; } = "SHA256";
    public string File { get; init; } = "checksums.sha256";
}

public sealed class PathInfo
{
    public string InstallRoot { get; init; } = ".";
    public string Config { get; init; } = "Config";
    public string Locales { get; init; } = "Locales";
    public string Data { get; init; } = "Data";
    public string Plugins { get; init; } = "Plugins";
    public string Backup { get; init; } = ".srlily-updater/backup";
    public string Staging { get; init; } = ".srlily-updater/staging";
}

public sealed class UpdatePolicyInfo
{
    public bool CheckOnStartup { get; init; } = true;
    public bool PromptBeforeInstall { get; init; } = true;
    public bool AtomicReplace { get; init; } = true;
    public bool VerifyChecksum { get; init; } = true;
    public bool RestartAfterUpdate { get; init; } = true;
}
