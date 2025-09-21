using System;
using System.Collections.Generic;
using System.Drawing;
using Tesseract;

namespace Highlighter
{
    public class OCRResult
    {
        public string Text { get; set; }
        public Rectangle BoundingBox { get; set; }
    }

    public static class OCRProcessor
    {
        public static List<OCRResult> GetWords(Bitmap bitmap, string tessdataPath)
        {
            var results = new List<OCRResult>();

            using (var engine = new TesseractEngine(tessdataPath, "eng", EngineMode.Default))
            {
                using (var img = PixConverter.ToPix(bitmap))
                {
                    using (var page = engine.Process(img))
                    {
                        using (var iter = page.GetIterator())
                        {
                            iter.Begin();
                            do
                            {
                                string word = iter.GetText(PageIteratorLevel.Word);
                                if (!string.IsNullOrWhiteSpace(word))
                                {
                                    if (iter.TryGetBoundingBox(PageIteratorLevel.Word, out var rect))
                                    {
                                        results.Add(new OCRResult
                                        {
                                            Text = word,
                                            BoundingBox = new Rectangle(rect.X1, rect.Y1, rect.Width, rect.Height)
                                        });
                                    }
                                }
                            } while (iter.Next(PageIteratorLevel.Word));
                        }
                    }
                }
            }

            return results;
        }
    }
}
