using System.Text.Json;

namespace Srlily.UpdaterTset.Services;

public static class ConfigService
{
    public static Dictionary<string, object?> Load(string baseDirectory)
    {
        var path = Path.Combine(baseDirectory, "Config", "appsettings.json");
        if (!File.Exists(path))
        {
            return new Dictionary<string, object?>();
        }

        try
        {
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            return Flatten(doc.RootElement, "");
        }
        catch (Exception ex)
        {
            return new Dictionary<string, object?>
            {
                ["__error"] = ex.Message
            };
        }
    }

    private static Dictionary<string, object?> Flatten(JsonElement element, string prefix)
    {
        var result = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);

        foreach (var prop in element.EnumerateObject())
        {
            var key = string.IsNullOrEmpty(prefix) ? prop.Name : $"{prefix}:{prop.Name}";
            switch (prop.Value.ValueKind)
            {
                case JsonValueKind.Object:
                    foreach (var (k, v) in Flatten(prop.Value, key))
                    {
                        result[k] = v;
                    }
                    break;
                case JsonValueKind.Array:
                    result[key] = string.Join(", ",
                        prop.Value.EnumerateArray().Select(e => e.ToString()));
                    break;
                case JsonValueKind.String:
                    result[key] = prop.Value.GetString();
                    break;
                case JsonValueKind.Number:
                    result[key] = prop.Value.GetRawText();
                    break;
                case JsonValueKind.True:
                case JsonValueKind.False:
                    result[key] = prop.Value.GetBoolean();
                    break;
                default:
                    result[key] = null;
                    break;
            }
        }

        return result;
    }
}

public static class LocaleService
{
    public static Dictionary<string, string> Load(string culture, string baseDirectory)
    {
        var path = Path.Combine(baseDirectory, "Locales", $"{culture}.json");
        if (!File.Exists(path))
        {
            var fallback = Path.Combine(baseDirectory, "Locales", "en-US.json");
            path = File.Exists(fallback) ? fallback : path;
        }

        if (!File.Exists(path))
        {
            return new Dictionary<string, string>();
        }

        try
        {
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            var result = new Dictionary<string, string>(StringComparer.Ordinal);
            foreach (var prop in doc.RootElement.EnumerateObject())
            {
                result[prop.Name] = prop.Value.GetString() ?? "";
            }
            return result;
        }
        catch
        {
            return new Dictionary<string, string>();
        }
    }

    public static IReadOnlyList<string> AvailableCultures(string baseDirectory)
    {
        var dir = Path.Combine(baseDirectory, "Locales");
        if (!Directory.Exists(dir))
        {
            return [];
        }

        return Directory.GetFiles(dir, "*.json")
            .Select(Path.GetFileNameWithoutExtension)
            .Where(n => !string.IsNullOrEmpty(n))
            .Cast<string>()
            .OrderBy(n => n, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }
}

public static class FileInventory
{
    private static readonly string[] Roots = ["Config", "Locales", "Data", "Plugins", "Assets"];

    public static IEnumerable<string> Collect(string baseDirectory)
    {
        foreach (var root in Roots)
        {
            var dir = Path.Combine(baseDirectory, root);
            if (!Directory.Exists(dir))
            {
                continue;
            }

            foreach (var file in Directory.EnumerateFiles(dir, "*", SearchOption.AllDirectories))
            {
                var rel = Path.GetRelativePath(baseDirectory, file).Replace('\\', '/');
                yield return $"{rel}\t{new FileInfo(file).Length}";
            }
        }

        foreach (var name in new[] { "Srlily.UpdaterTset.exe", "latest.json", "README.md", "CHANGELOG.md" })
        {
            var path = Path.Combine(baseDirectory, name);
            if (File.Exists(path))
            {
                yield return $"{name}\t{new FileInfo(path).Length}";
            }
        }
    }
}
