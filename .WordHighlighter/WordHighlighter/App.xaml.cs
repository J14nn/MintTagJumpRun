using System.Collections.Generic;
using System.Windows;

namespace WordHighlighter
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            var words = new List<string>
            {
                "Spieler",
                "Sprung"
            };

            var overlay = new OverlayWindow("Godot Engine", words);
            overlay.Show();
        }
    }
}
