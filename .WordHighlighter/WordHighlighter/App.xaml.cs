using System.Windows;

namespace WordHighlighter
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            var overlay = new OverlayWindow("Godot Engine", "HinweisTruhe");
            overlay.Show();
        }
    }
}