using Highlighter;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;
using Tesseract;

namespace WordHighlighter
{
    public partial class OverlayWindow : Window
    {
        public OverlayWindow(string targetWindowKeyword, string wordToHighlight)
        {
            InitializeComponent();

            var hwnd = new System.Windows.Interop.WindowInteropHelper(this).Handle;
            int exStyle = NativeMethods.GetWindowLong(hwnd, NativeMethods.GWL_EXSTYLE);
            NativeMethods.SetWindowLong(hwnd, NativeMethods.GWL_EXSTYLE, exStyle | 0x20);

            var bounds = ScreenCapture.GetWindowBounds(targetWindowKeyword);
            Left = bounds.Left;
            Top = bounds.Top;
            Width = bounds.Width;
            Height = bounds.Height;

            var bmpSource = ScreenCapture.CaptureWindow(targetWindowKeyword);
            var words = OCRProcessor.GetWords(bmpSource);
            var targetWords = words.FindAll(w => w.Text.Equals(wordToHighlight, System.StringComparison.OrdinalIgnoreCase));

            DrawHighlights(targetWords);
        }
        private void DrawHighlights(List<OCRResult> words)
        {
            foreach (var word in words)
            {
                double x = word.BoundingBox.X;
                double y = word.BoundingBox.Y;
                double w = word.BoundingBox.Width * 1.5;
                double h = word.BoundingBox.Height * 1.5;

                var ellipse = new Ellipse
                {
                    Width = w,
                    Height = h,
                    Fill = new SolidColorBrush(Color.FromArgb(128, 255, 255, 0)),
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