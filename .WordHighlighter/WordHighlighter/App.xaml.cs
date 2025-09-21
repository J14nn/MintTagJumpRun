using System.IO;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;

namespace WordHighlighter
{

    public partial class App : Application
    {
        private CancellationTokenSource _cts = new();
        private OverlayWindow _overlayWindow;
        private string _workingFolder;
        private string _tessdataPath;

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            string configPath = (e.Args.Length >= 2 && !string.IsNullOrWhiteSpace(e.Args[1]))
                ? e.Args[1]
                : "config.json";

            if (!File.Exists(configPath))
            {
                MessageBox.Show($"Missing config file: {configPath}");
                Shutdown();
                return;
            }

            AppConfig config;
            try
            {
                string json = File.ReadAllText(configPath);
                config = JsonSerializer.Deserialize<AppConfig>(json);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to read config.json: {ex.Message}");
                Shutdown();
                return;
            }

            if (config == null || string.IsNullOrWhiteSpace(config.TargetWindowKeyword))
            {
                MessageBox.Show("Invalid config.json");
                Shutdown();
                return;
            }

            _workingFolder = string.IsNullOrWhiteSpace(config.WorkingFolder)
                ? Directory.GetCurrentDirectory()
                : config.WorkingFolder;

            _tessdataPath = string.IsNullOrWhiteSpace(config.TessdataPath)
                ? Path.Combine(_workingFolder, "tessdata")
                : config.TessdataPath;

            if (!Directory.Exists(_tessdataPath))
            {
                MessageBox.Show($"Error: 'tessdata' not found in {_tessdataPath}");
                Shutdown();
                return;
            }

            if (e.Args.Length < 1)
            {
                MessageBox.Show("Usage: WordHighlighter.exe \"Word1,Word2,...\" \"config.json path\"");
                Shutdown();
                return;
            }

            var words = e.Args[0]
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(w => w.Trim())
                .ToList();

            _overlayWindow = new OverlayWindow(config.TargetWindowKeyword, words, _tessdataPath);
            _overlayWindow.Show();

            StartFileMonitor();
        }

        private void StartFileMonitor()
        {
            string filePath = Path.Combine(_workingFolder, "control.txt");
            Task.Run(async () =>
            {
                while (!_cts.IsCancellationRequested)
                {
                    try
                    {
                        if (File.Exists(filePath))
                        {
                            string content = File.ReadAllText(filePath).Trim().ToLowerInvariant();
                            if (!string.IsNullOrEmpty(content))
                            {
                                File.WriteAllText(filePath, string.Empty);

                                if (content == "close")
                                {
                                    Dispatcher.Invoke(Shutdown);
                                    return;
                                }
                                else if (content == "search")
                                {
                                    _overlayWindow.Dispatcher.Invoke(() => _overlayWindow.PollForWord());
                                }
                            }
                        }
                    }
                    catch { }

                    await Task.Delay(1000);
                }
            }, _cts.Token);
        }

        protected override void OnExit(ExitEventArgs e)
        {
            _cts.Cancel();
            base.OnExit(e);
        }
    }
}
