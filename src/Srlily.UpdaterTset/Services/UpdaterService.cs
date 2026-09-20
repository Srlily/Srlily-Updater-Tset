using System.Diagnostics;
using System.Text.Json;

namespace Srlily.UpdaterTset.Services;

public enum UpdaterMode
{
    Check,
    Apply,
    Silent,
    Ui
}

public sealed class UpdaterLaunchResult
{
    public required bool Success { get; init; }
    public required string Message { get; init; }
    public string? UpdaterPath { get; init; }
    public int? ExitCode { get; init; }
    public string? CommandLine { get; init; }
}

public static class UpdaterService
{
    public const string ConfigFileName = "updater.config.json";

    public static string? FindUpdaterExecutable(string installRoot)
    {
        var candidates = new List<string>();

        var env = Environment.GetEnvironmentVariable("SRLILY_UPDATER");
        if (!string.IsNullOrWhiteSpace(env))
        {
            candidates.Add(env);
        }

        candidates.Add(Path.Combine(installRoot, "updater", "Updater.exe"));
        candidates.Add(Path.Combine(installRoot, "tools", "Updater.exe"));

        var dir = installRoot;
        for (var i = 0; i < 4 && !string.IsNullOrEmpty(dir); i++)
        {
            candidates.Add(Path.Combine(dir, "Srlily-Updater", "dist", "Updater.exe"));
            candidates.Add(Path.Combine(dir, "Srlily-Updater", "updater", "Updater.exe"));
            dir = Path.GetDirectoryName(dir.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar));
        }

        candidates.Add(@"E:\Github\Srlily-Updater\dist\Updater.exe");

        foreach (var c in candidates)
        {
            if (!string.IsNullOrWhiteSpace(c) && File.Exists(c))
            {
                return Path.GetFullPath(c);
            }
        }

        return null;
    }

    public static bool HasHostConfig(string installRoot)
        => File.Exists(Path.Combine(installRoot, ConfigFileName))
           || File.Exists(Path.Combine(installRoot, "latest.json"));

    public static string? ReadConfiguredAppId(string installRoot)
    {
        var path = Path.Combine(installRoot, ConfigFileName);
        if (!File.Exists(path))
        {
            return null;
        }

        try
        {
            using var doc = JsonDocument.Parse(File.ReadAllText(path));
            if (doc.RootElement.TryGetProperty("appId", out var id))
            {
                return id.GetString();
            }
        }
        catch
        {
            // ignore malformed host config
        }

        return null;
    }

    public static UpdaterLaunchResult Launch(string installRoot, UpdaterMode mode, string? updaterPath = null)
    {
        installRoot = Path.GetFullPath(installRoot);
        var exe = updaterPath ?? FindUpdaterExecutable(installRoot);
        if (exe is null || !File.Exists(exe))
        {
            return new UpdaterLaunchResult
            {
                Success = false,
                UpdaterPath = exe,
                Message =
                    "未找到 Srlily-Updater（Updater.exe）。\n" +
                    "请先构建更新器，或设置环境变量 SRLILY_UPDATER 指向 Updater.exe，\n" +
                    "也可将 Updater.exe 放到安装目录的 updater\\ 下。"
            };
        }

        if (!HasHostConfig(installRoot))
        {
            return new UpdaterLaunchResult
            {
                Success = false,
                UpdaterPath = exe,
                Message =
                    $"安装目录缺少更新宿主配置：\n{ConfigFileName} 或 latest.json\n" +
                    $"目录：{installRoot}"
            };
        }

        var args = BuildArgs(mode, installRoot);

        try
        {
            // Launch Updater.exe directly — never via cmd.exe.
            // UI: shell-execute GUI process.
            // Check/Apply/Silent: hidden window, no console flash.
            var psi = new ProcessStartInfo
            {
                FileName = exe,
                Arguments = args,
                WorkingDirectory = installRoot,
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardOutput = false,
                RedirectStandardError = false
            };

            if (mode == UpdaterMode.Ui)
            {
                psi.UseShellExecute = true;
                psi.CreateNoWindow = false;
                psi.WindowStyle = ProcessWindowStyle.Normal;
                Process.Start(psi);
                return new UpdaterLaunchResult
                {
                    Success = true,
                    UpdaterPath = exe,
                    Message = "已打开更新器界面。"
                };
            }

            using var proc = Process.Start(psi);
            if (proc is null)
            {
                return new UpdaterLaunchResult
                {
                    Success = false,
                    UpdaterPath = exe,
                    Message = "无法启动更新器进程。"
                };
            }

            proc.WaitForExit(120_000);
            var code = proc.HasExited ? proc.ExitCode : -1;
            var ok = code == 0;

            var summary = mode switch
            {
                UpdaterMode.Check when ok => "检查完成：当前已是最新或更新器已处理完毕。",
                UpdaterMode.Check => $"检查未通过（代码 {code}）。",
                UpdaterMode.Apply when ok => "更新已完成。",
                UpdaterMode.Apply => $"更新未完成（代码 {code}）。",
                UpdaterMode.Silent when ok => "静默更新完成。",
                _ => ok ? "更新器执行完成。" : $"更新器返回代码 {code}。"
            };

            return new UpdaterLaunchResult
            {
                Success = ok,
                UpdaterPath = exe,
                ExitCode = code,
                Message = summary
            };
        }
        catch (Exception ex)
        {
            return new UpdaterLaunchResult
            {
                Success = false,
                UpdaterPath = exe,
                Message = $"启动更新器失败：{ex.Message}"
            };
        }
    }

    private static string BuildArgs(UpdaterMode mode, string installRoot)
    {
        var verb = mode switch
        {
            UpdaterMode.Check => "--check",
            UpdaterMode.Apply => "--apply",
            UpdaterMode.Silent => "--silent",
            _ => "--ui"
        };
        return $"{verb} --root \"{installRoot}\"";
    }
}
