using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;

namespace WordHighlighter
{
    public partial class App : Application
    {
        private CancellationTokenSource _cts = new();
        OverlayWindow _overlayWindow;

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            string tessdataPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "tessdata");
            if (!Directory.Exists(tessdataPath))
            {
                MessageBox.Show("Error: 'tessdata' folder not found in the program directory.");
                Shutdown();
                return;
            }

            if (e.Args.Length < 2)
            {
                MessageBox.Show("Usage: WordHighlighter.exe \"TargetWindowKeyword\" \"Word1,Word2,...\"");
                Shutdown();
                return;
            }

            string targetWindowKeyword = e.Args[0];
            var words = e.Args[1].Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                  .Select(w => w.Trim())
                                  .ToList();

            _overlayWindow = new OverlayWindow(targetWindowKeyword, words);
            _overlayWindow.Show();

            StartFileMonitor();
        }

        private void StartFileMonitor()
        {
            string filePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "control.txt");

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
                    catch {}

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
