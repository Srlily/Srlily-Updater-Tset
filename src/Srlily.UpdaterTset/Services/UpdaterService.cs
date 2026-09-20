using System.Diagnostics;
using System.Text;
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
    public string? Output { get; init; }
    public bool UpdateAvailable { get; init; }
}

public static class UpdaterService
{
    public const string ConfigFileName = "updater.config.json";

    // Srlily-Updater documented exit codes
    private const int ExitUpToDate = 0;
    private const int ExitBadConfig = 2;
    private const int ExitNetwork = 3;
    private const int ExitVerify = 4;
    private const int ExitApply = 5;
    private const int ExitCancelled = 6;
    private const int ExitUpdateAvailable = 10;
    private const int ExitUpdated = 20;

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

    public static string BuildArguments(UpdaterMode mode, string installRoot)
    {
        // Updater.exe CLI (see Srlily-Updater --help):
        //   --root <dir> --check | --apply | --silent
        //   UI mode: only --root (no --check/--apply/--silent). There is NO --ui flag.
        var root = $"--root \"{installRoot}\"";
        var config = Path.Combine(installRoot, ConfigFileName);
        var cfg = File.Exists(config) ? $" --config \"{config}\"" : "";

        return mode switch
        {
            UpdaterMode.Check => $"--check {root}{cfg}",
            UpdaterMode.Apply => $"--apply {root}{cfg}",
            UpdaterMode.Silent => $"--silent {root}{cfg}",
            _ => $"{root}{cfg}"
        };
    }

    public static string DescribeExitCode(int code) => code switch
    {
        ExitUpToDate => "当前已是最新版本",
        ExitUpdateAvailable => "发现新版本",
        ExitUpdated => "更新已完成",
        ExitBadConfig => "更新配置无效",
        ExitNetwork => "无法连接更新源（网络或 GitHub 错误）",
        ExitVerify => "更新包校验失败",
        ExitApply => "安装更新失败",
        ExitCancelled => "操作已取消",
        _ => $"更新器退出代码 {code}"
    };

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
                    "未找到 Srlily-Updater（Updater.exe）。\n\n" +
                    "请任选其一：\n" +
                    "1. 设置环境变量 SRLILY_UPDATER 指向 Updater.exe\n" +
                    "2. 将 Updater.exe 复制到安装目录 updater\\ 下\n" +
                    $"3. 使用本机路径 E:\\Github\\Srlily-Updater\\dist\\Updater.exe"
            };
        }

        if (!HasHostConfig(installRoot))
        {
            return new UpdaterLaunchResult
            {
                Success = false,
                UpdaterPath = exe,
                Message =
                    $"安装目录缺少更新配置：\n{ConfigFileName} 或 latest.json\n\n" +
                    $"目录：{installRoot}"
            };
        }

        var args = BuildArguments(mode, installRoot);
        var commandLine = $"\"{exe}\" {args}";
        AppendHostLog(installRoot, $"LAUNCH {mode}: {commandLine}");

        try
        {
            if (mode == UpdaterMode.Ui)
            {
                // GUI updater — no cmd window. Args must NOT include --check/--apply/--silent.
                var psi = new ProcessStartInfo
                {
                    FileName = exe,
                    Arguments = args,
                    WorkingDirectory = installRoot,
                    UseShellExecute = true,
                    CreateNoWindow = false,
                    WindowStyle = ProcessWindowStyle.Normal
                };
                Process.Start(psi);
                AppendHostLog(installRoot, "UI process started");
                return new UpdaterLaunchResult
                {
                    Success = true,
                    UpdaterPath = exe,
                    CommandLine = commandLine,
                    Message = "已打开更新器界面。"
                };
            }

            // Headless check/apply: hidden, capture stdout/stderr for feedback.
            var headless = new ProcessStartInfo
            {
                FileName = exe,
                Arguments = args,
                WorkingDirectory = installRoot,
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8
            };

            using var proc = Process.Start(headless);
            if (proc is null)
            {
                return new UpdaterLaunchResult
                {
                    Success = false,
                    UpdaterPath = exe,
                    CommandLine = commandLine,
                    Message = "无法启动更新器进程。"
                };
            }

            var stdout = proc.StandardOutput.ReadToEnd();
            var stderr = proc.StandardError.ReadToEnd();
            proc.WaitForExit(120_000);
            var code = proc.HasExited ? proc.ExitCode : -1;
            var output = (stdout + "\n" + stderr).Trim();
            AppendHostLog(installRoot, $"EXIT {code}: {Truncate(output, 400)}");

            var desc = DescribeExitCode(code);
            var updateAvailable = code == ExitUpdateAvailable;
            var ok = code is ExitUpToDate or ExitUpdateAvailable or ExitUpdated;

            var sb = new StringBuilder();
            sb.AppendLine(desc);
            sb.AppendLine();
            sb.AppendLine($"退出代码：{code}");
            if (!string.IsNullOrWhiteSpace(output))
            {
                sb.AppendLine();
                sb.AppendLine(Truncate(output, 800));
            }
            sb.AppendLine();
            sb.AppendLine($"更新器：{exe}");

            return new UpdaterLaunchResult
            {
                Success = ok,
                UpdaterPath = exe,
                ExitCode = code,
                CommandLine = commandLine,
                Output = output,
                UpdateAvailable = updateAvailable,
                Message = sb.ToString().Trim()
            };
        }
        catch (Exception ex)
        {
            AppendHostLog(installRoot, $"ERROR {ex.Message}");
            return new UpdaterLaunchResult
            {
                Success = false,
                UpdaterPath = exe,
                CommandLine = commandLine,
                Message = $"启动更新器失败：{ex.Message}"
            };
        }
    }

    public static void AppendHostLog(string installRoot, string line)
    {
        try
        {
            var dir = Path.Combine(installRoot, ".srlily-updater");
            Directory.CreateDirectory(dir);
            var path = Path.Combine(dir, "host-launch.log");
            File.AppendAllText(path, $"[{DateTimeOffset.Now:yyyy-MM-dd HH:mm:ss}] {line}{Environment.NewLine}");
        }
        catch
        {
            // logging must never break launch
        }
    }

    private static string Truncate(string s, int max)
        => s.Length <= max ? s : s[..max] + "…";
}
