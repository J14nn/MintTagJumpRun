using Highlighter;
using System.Collections.Generic;
using System.Drawing;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;
using System.Windows.Threading;
using Tesseract;

namespace WordHighlighter
{
    public partial class OverlayWindow : Window
    {
        private readonly IList<string> _words;
        private int _currentIndex = 0;
        private readonly DispatcherTimer _pollTimer;
        private readonly string _targetWindowKeyword;
        private Bitmap _lastBmp;
        private List<OCRResult> _lastOcrWords;

        public OverlayWindow(string targetWindowKeyword, IList<string> wordsToHighlight)
        {
            InitializeComponent();
            _targetWindowKeyword = targetWindowKeyword;
            _words = wordsToHighlight;

            var hwnd = new System.Windows.Interop.WindowInteropHelper(this).Handle;
            int exStyle = NativeMethods.GetWindowLong(hwnd, NativeMethods.GWL_EXSTYLE);
            NativeMethods.SetWindowLong(hwnd, NativeMethods.GWL_EXSTYLE, exStyle | 0x20);

            var bounds = ScreenCapture.GetWindowBounds(targetWindowKeyword);
            Left = bounds.Left;
            Top = bounds.Top;
            Width = bounds.Width;
            Height = bounds.Height;

            _pollTimer = new DispatcherTimer
            {
                Interval = System.TimeSpan.FromMilliseconds(500)
            };
            _pollTimer.Tick += PollForWord;
            _pollTimer.Start();
        }


        private void PollForWord(object sender, System.EventArgs e)
        {
            if (_currentIndex >= _words.Count)
            {
                _pollTimer.Stop();
                return;
            }

            string current = _words[_currentIndex];
            string next = (_currentIndex + 1 < _words.Count) ? _words[_currentIndex + 1] : null;

            var bmp = ScreenCapture.CaptureWindow(_targetWindowKeyword);

            if (_lastBmp == null || HasBitmapChanged(bmp))
            {
                OverlayCanvas.Children.Clear();
                _lastOcrWords = OCRProcessor.GetWords(bmp);
                _lastBmp?.Dispose();
                _lastBmp = (Bitmap)bmp.Clone();
            }

            var ocrWords = _lastOcrWords;

            var currentMatches = ocrWords.FindAll(w =>
                w.Text.Equals(current, System.StringComparison.OrdinalIgnoreCase));

            var nextMatches = next != null
                ? ocrWords.FindAll(w =>
                    w.Text.Equals(next, System.StringComparison.OrdinalIgnoreCase))
                : new List<OCRResult>();

            if (nextMatches.Count > 0)
            {
                _currentIndex++;
                DrawHighlights(new List<OCRResult>());
                return;
            }

            if (currentMatches.Count > 0)
            {
                DrawHighlights(currentMatches);
            }
            else if (_currentIndex > 0)
            {
                string previousWord = _words[_currentIndex - 1];
                var previousMatches = ocrWords.FindAll(w =>
                    w.Text.Equals(previousWord, System.StringComparison.OrdinalIgnoreCase));

                DrawHighlights(previousMatches);
            }
            else
            {
                DrawHighlights(new List<OCRResult>());
            }
        }

        private void DrawHighlights(List<OCRResult> words)
        {
            OverlayCanvas.Children.Clear();
            foreach (var word in words)
            {
                double x = word.BoundingBox.X;
                double y = word.BoundingBox.Y;
                double w = word.BoundingBox.Width * 2.5;
                double h = word.BoundingBox.Height * 3;

                var ellipse = new Ellipse
                {
                    Width = w,
                    Height = h,
                    Fill = null,
                    Stroke = new SolidColorBrush(System.Windows.Media.Colors.Yellow),
                    StrokeThickness = 4
                };

                Canvas.SetLeft(ellipse, x - (w - word.BoundingBox.Width) / 2);
                Canvas.SetTop(ellipse, y - (h - word.BoundingBox.Height) / 2);

                OverlayCanvas.Children.Add(ellipse);
            }
        }

        private static class NativeMethods
        {
            public const int GWL_EXSTYLE = -20;

            [System.Runtime.InteropServices.DllImport("user32.dll")]
            public static extern int GetWindowLong(System.IntPtr hWnd, int nIndex);

            [System.Runtime.InteropServices.DllImport("user32.dll")]
            public static extern int SetWindowLong(System.IntPtr hWnd, int nIndex, int dwNewLong);
        }

        private bool HasBitmapChanged(Bitmap bmp, double threshold = 0.01)
        {
            if (_lastBmp == null) return true;
            if (bmp.Width != _lastBmp.Width || bmp.Height != _lastBmp.Height) return true;

            int changedPixels = 0;
            int totalSamples = 0;

            for (int x = 0; x < bmp.Width; x += 50)
            {
                for (int y = 0; y < bmp.Height; y += 50)
                {
                    totalSamples++;
                    if (bmp.GetPixel(x, y) != _lastBmp.GetPixel(x, y))
                        changedPixels++;
                }
            }

            return ((double)changedPixels / totalSamples) >= threshold;
        }

    }
}
