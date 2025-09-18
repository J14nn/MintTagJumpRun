using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;

namespace WordHighlighter
{
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            if (e.Args.Length < 2)
            {
                MessageBox.Show("Usage: WordHighlighter.exe <TargetWindowKeyword> <Word1,Word2,...>");
                Shutdown();
                return;
            }

            string targetWindowKeyword = e.Args[0];

            var words = e.Args[1].Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                  .Select(w => w.Trim())
                                  .ToList();

            var overlay = new OverlayWindow(targetWindowKeyword, words);
            overlay.Show();
        }
    }
}
