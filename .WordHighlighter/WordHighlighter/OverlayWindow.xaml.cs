using Highlighter;
using System.Collections.Generic;
using System.Drawing;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;

namespace WordHighlighter
{
    public partial class OverlayWindow : Window
    {
        private readonly IList<string> _words;
        private readonly string _targetWindowKeyword;
        private readonly string _tessdataPath;

        public OverlayWindow(string targetWindowKeyword, IList<string> wordsToHighlight, string tessdataPath)
        {
            InitializeComponent();
            _targetWindowKeyword = targetWindowKeyword;
            _words = wordsToHighlight;
            _tessdataPath = tessdataPath;

            //string argsInfo = $"TargetWindowKeyword: {_targetWindowKeyword}\n" +
            //      $"Words: {string.Join(", ", _words)}\n" +
            //      $"TessdataPath: {_tessdataPath}";
            //MessageBox.Show(argsInfo, "Debug Args");

            var hwnd = new System.Windows.Interop.WindowInteropHelper(this).Handle;
            int exStyle = NativeMethods.GetWindowLong(hwnd, NativeMethods.GWL_EXSTYLE);
            NativeMethods.SetWindowLong(hwnd, NativeMethods.GWL_EXSTYLE, exStyle | 0x08000000 | 0x20 | 0x80);

            var bounds = ScreenCapture.GetWindowBounds(targetWindowKeyword);
            Left = bounds.Left;
            Top = bounds.Top;
            Width = bounds.Width;
            Height = bounds.Height;
        }

        public void PollForWord()
        {
            var bmp = ScreenCapture.CaptureWindow(_targetWindowKeyword);
            var ocrWords = OCRProcessor.GetWords(bmp, _tessdataPath);

            for (int i = _words.Count - 1; i >= 0; i--)
            {
                var matches = ocrWords.FindAll(w =>
                    w.Text.Equals(_words[i], System.StringComparison.OrdinalIgnoreCase));

                if (matches.Count > 0)
                {
                    DrawHighlights(matches);
                    return;
                }
            }

            OverlayCanvas.Children.Clear();
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
    }
}
