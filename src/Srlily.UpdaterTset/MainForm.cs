using System.Diagnostics;
using Srlily.UpdaterTset.Models;
using Srlily.UpdaterTset.Services;

namespace Srlily.UpdaterTset;

public sealed class MainForm : Form
{
    private readonly AppInfo _app;
    private readonly System.Windows.Forms.Timer _clockTimer;
    private Label _versionLabel = null!;
    private ToolStripStatusLabel _statusLabel = null!;
    private ListBox _fileList = null!;
    private ComboBox _localeBox = null!;
    private TextBox _localePreview = null!;
    private TabControl _tabs = null!;

    public MainForm()
    {
        _app = AppInfo.Load();
        _clockTimer = new System.Windows.Forms.Timer { Interval = 1000 };

        Text = $"{_app.Name} v{_app.Version}";
        StartPosition = FormStartPosition.CenterScreen;
        MinimumSize = new Size(720, 520);
        Size = new Size(860, 600);
        Font = new Font("Segoe UI", 9F);
        BackColor = Color.FromArgb(243, 245, 248);
        KeyPreview = true;

        BuildUi();
        Load += (_, _) =>
        {
            RefreshFileList();
            LoadLocalePreview();
            _statusLabel.Text = $"已启动 · {_app.StartedAt:HH:mm:ss}";
            _clockTimer.Start();
        };
        _clockTimer.Tick += (_, _) =>
        {
            _statusLabel.Text = $"运行中 · {DateTime.Now:HH:mm:ss} · PID {Environment.ProcessId}";
        };
        KeyDown += (_, e) =>
        {
            if (e.KeyCode == Keys.F5)
            {
                RefreshFileList();
                LoadLocalePreview();
                e.Handled = true;
            }
        };
    }

    private void BuildUi()
    {
        var header = new Panel
        {
            Dock = DockStyle.Top,
            Height = 88,
            BackColor = Color.White,
            Padding = new Padding(20, 14, 20, 10)
        };

        var title = new Label
        {
            Text = _app.Name,
            Font = new Font("Segoe UI", 16F, FontStyle.Bold),
            AutoSize = true,
            Location = new Point(20, 14),
            ForeColor = Color.FromArgb(26, 29, 33)
        };

        _versionLabel = new Label
        {
            Text = $"v{_app.Version}  ·  {_app.Runtime}  ·  {_app.ProcessArchitecture}",
            Font = new Font("Segoe UI", 9.5F),
            AutoSize = true,
            Location = new Point(22, 48),
            ForeColor = Color.FromArgb(74, 80, 88)
        };

        var badge = new Label
        {
            Text = "更新测试目标",
            AutoSize = true,
            Anchor = AnchorStyles.Top | AnchorStyles.Right,
            BackColor = Color.FromArgb(232, 240, 254),
            ForeColor = Color.FromArgb(27, 79, 196),
            Font = new Font("Segoe UI", 9F, FontStyle.Bold),
            Padding = new Padding(10, 6, 10, 6),
            Location = new Point(header.Width - 140, 22)
        };
        badge.Location = new Point(620, 22);

        header.Controls.Add(title);
        header.Controls.Add(_versionLabel);
        header.Controls.Add(badge);

        _tabs = new TabControl { Dock = DockStyle.Fill, Padding = new Point(12, 4) };

        _tabs.TabPages.Add(BuildOverviewPage());
        _tabs.TabPages.Add(BuildFilesPage());
        _tabs.TabPages.Add(BuildLocalePage());
        _tabs.TabPages.Add(BuildConfigPage());

        var statusStrip = new StatusStrip { BackColor = Color.White };
        _statusLabel = new ToolStripStatusLabel("就绪") { Spring = true, TextAlign = ContentAlignment.MiddleLeft };
        statusStrip.Items.Add(_statusLabel);
        statusStrip.Items.Add(new ToolStripStatusLabel(_app.OsDescription.Length > 48
            ? _app.OsDescription[..48] + "…"
            : _app.OsDescription));

        Controls.Add(_tabs);
        Controls.Add(statusStrip);
        Controls.Add(header);
    }

    private TabPage BuildOverviewPage()
    {
        var page = new TabPage("概览") { BackColor = Color.White, Padding = new Padding(16) };

        var grid = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            ColumnCount = 2,
            Padding = new Padding(4)
        };
        grid.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 140));
        grid.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        void AddRow(string key, string value)
        {
            var r = grid.RowCount++;
            grid.Controls.Add(new Label
            {
                Text = key,
                Font = new Font("Segoe UI", 9F, FontStyle.Bold),
                ForeColor = Color.FromArgb(74, 80, 88),
                AutoSize = true,
                Margin = new Padding(0, 6, 8, 6)
            }, 0, r);
            grid.Controls.Add(new Label
            {
                Text = value,
                AutoSize = true,
                Margin = new Padding(0, 6, 0, 6),
                ForeColor = Color.FromArgb(26, 29, 33)
            }, 1, r);
        }

        AddRow("应用 ID", _app.AppId);
        AddRow("版本", _app.Version);
        AddRow("文件版本", _app.FileVersion);
        AddRow("信息版本", _app.InformationalVersion);
        AddRow("运行时", _app.Runtime);
        AddRow("框架", _app.Framework);
        AddRow("架构", _app.ProcessArchitecture);
        AddRow("操作系统", _app.OsDescription);
        AddRow("基目录", _app.BaseDirectory);
        AddRow("更新通道", _app.Manifest?.Channel ?? "—");
        AddRow("发布 API", _app.Manifest?.Releases?.Api ?? "—");
        AddRow("校验算法", _app.Manifest?.Checksum?.Algorithm ?? "—");

        var actions = new FlowLayoutPanel
        {
            Dock = DockStyle.Bottom,
            Height = 48,
            FlowDirection = FlowDirection.LeftToRight,
            Padding = new Padding(0, 8, 0, 0)
        };

        var btnFiles = new Button { Text = "刷新文件清单 (F5)", AutoSize = true, Margin = new Padding(0, 0, 8, 0) };
        btnFiles.Click += (_, _) => { RefreshFileList(); LoadLocalePreview(); };

        var btnOpen = new Button { Text = "打开安装目录", AutoSize = true, Margin = new Padding(0, 0, 8, 0) };
        btnOpen.Click += (_, _) =>
        {
            try
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = _app.BaseDirectory,
                    UseShellExecute = true
                });
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.Message, "无法打开目录", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        };

        var btnGithub = new Button { Text = "GitHub 仓库", AutoSize = true };
        btnGithub.Click += (_, _) =>
        {
            try
            {
                Process.Start(new ProcessStartInfo
                {
                    FileName = _app.Manifest?.Homepage ?? "https://github.com/Srlily/Srlily-Updater-Tset",
                    UseShellExecute = true
                });
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, ex.Message, "无法打开链接", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        };

        actions.Controls.Add(btnFiles);
        actions.Controls.Add(btnOpen);
        actions.Controls.Add(btnGithub);

        page.Controls.Add(grid);
        page.Controls.Add(actions);
        return page;
    }

    private TabPage BuildFilesPage()
    {
        var page = new TabPage("文件清单") { BackColor = Color.White, Padding = new Padding(12) };

        var hint = new Label
        {
            Dock = DockStyle.Top,
            Height = 28,
            Text = "发布包内各类文件（用于验证更新替换是否完整）· F5 刷新",
            ForeColor = Color.FromArgb(74, 80, 88)
        };

        _fileList = new ListBox
        {
            Dock = DockStyle.Fill,
            Font = new Font("Cascadia Mono", 9.5F),
            IntegralHeight = false,
            BorderStyle = BorderStyle.FixedSingle
        };

        page.Controls.Add(_fileList);
        page.Controls.Add(hint);
        return page;
    }

    private TabPage BuildLocalePage()
    {
        var page = new TabPage("本地化") { BackColor = Color.White, Padding = new Padding(16) };

        var top = new FlowLayoutPanel { Dock = DockStyle.Top, Height = 40 };
        top.Controls.Add(new Label { Text = "文化：", AutoSize = true, Padding = new Padding(0, 6, 0, 0) });

        _localeBox = new ComboBox
        {
            DropDownStyle = ComboBoxStyle.DropDownList,
            Width = 160,
            Margin = new Padding(4, 4, 8, 4)
        };
        foreach (var c in LocaleService.AvailableCultures(_app.BaseDirectory))
        {
            _localeBox.Items.Add(c);
        }
        if (_localeBox.Items.Count > 0)
        {
            _localeBox.SelectedIndex = 0;
        }
        _localeBox.SelectedIndexChanged += (_, _) => LoadLocalePreview();
        top.Controls.Add(_localeBox);

        _localePreview = new TextBox
        {
            Multiline = true,
            ReadOnly = true,
            ScrollBars = ScrollBars.Vertical,
            Dock = DockStyle.Fill,
            Font = new Font("Cascadia Mono", 9.5F),
            BorderStyle = BorderStyle.FixedSingle,
            BackColor = Color.FromArgb(250, 251, 252)
        };

        page.Controls.Add(_localePreview);
        page.Controls.Add(top);
        return page;
    }

    private TabPage BuildConfigPage()
    {
        var page = new TabPage("配置") { BackColor = Color.White, Padding = new Padding(16) };

        var box = new TextBox
        {
            Multiline = true,
            ReadOnly = true,
            ScrollBars = ScrollBars.Both,
            Dock = DockStyle.Fill,
            WordWrap = false,
            Font = new Font("Cascadia Mono", 9.5F),
            BorderStyle = BorderStyle.FixedSingle,
            BackColor = Color.FromArgb(250, 251, 252)
        };

        var cfg = ConfigService.Load(_app.BaseDirectory);
        var lines = cfg.Count == 0
            ? ["(未找到 Config/appsettings.json)"]
            : cfg.OrderBy(kv => kv.Key, StringComparer.OrdinalIgnoreCase)
                 .Select(kv => $"{kv.Key} = {kv.Value}");
        box.Text = string.Join(Environment.NewLine, lines);

        page.Controls.Add(box);
        return page;
    }

    private void RefreshFileList()
    {
        if (_fileList is null)
        {
            return;
        }

        _fileList.BeginUpdate();
        _fileList.Items.Clear();
        foreach (var line in FileInventory.Collect(_app.BaseDirectory))
        {
            _fileList.Items.Add(line);
        }
        _fileList.EndUpdate();
    }

    private void LoadLocalePreview()
    {
        if (_localePreview is null || _localeBox is null)
        {
            return;
        }

        var culture = _localeBox.SelectedItem as string ?? "zh-CN";
        var map = LocaleService.Load(culture, _app.BaseDirectory);
        _localePreview.Text = map.Count == 0
            ? "(无本地化数据)"
            : string.Join(Environment.NewLine, map.Select(kv => $"{kv.Key,-28} {kv.Value}"));
    }
}
