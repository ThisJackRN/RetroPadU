// RetroPadU.exe: a window for scripts\build-wiivc.ps1. Pick the disc, the pack and
// optionally a save, press Build. The build itself still runs in the script, so the
// window and BUILD.cmd always produce the same image.
//
// Built by gui\build.cmd with the C# compiler that ships with Windows (.NET Framework
// 4.x, C# 5), so it needs nothing installed. The controls are drawn by hand so the
// window looks the same on Windows 10 and 11, in light and dark mode.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Windows.Forms;
using Microsoft.Win32;

[assembly: System.Reflection.AssemblyTitle("RetroPadU")]
[assembly: System.Reflection.AssemblyProduct("RetroPadU")]
[assembly: System.Reflection.AssemblyDescription("Retro Rewind WiiVC builder")]

namespace RetroPadU
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            // gui\build.cmd uses this to draw the exe icon.
            if (args.Length == 2 && args[0] == "--write-icon")
            {
                Art.WriteIcon(args[1]);
                return;
            }
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            using (Graphics g = Graphics.FromHwnd(IntPtr.Zero)) Theme.Init(g.DpiX / 96f);

            AppPaths paths;
            try { paths = AppPaths.Resolve(AppDomain.CurrentDomain.BaseDirectory.TrimEnd('\\')); }
            catch (Exception ex)
            {
                MessageBox.Show("RetroPadU could not unpack its files:\n\n" + ex.Message, "RetroPadU", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            if (paths == null)
            {
                MessageBox.Show("This copy of RetroPadU.exe has no build files inside it. Keep it in the RetroPadU folder, next to BUILD.cmd.",
                    "RetroPadU", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            Application.Run(new MainForm(paths));
        }
    }

    // Where the build runs. RetroPadU.exe carries the build script, kit, loader, SD card
    // homebrew and wit inside it, and unpacks them once per version to
    // %LOCALAPPDATA%\RetroPadU, so the exe works on its own. Next to BUILD.cmd in a
    // RetroPadU folder it uses that folder's script and output instead (only wit
    // still comes from the exe), so edits to the script take effect without a rebuild.
    class AppPaths
    {
        public string ExeDir, ScriptRoot, Output, Work, Wit;
        public bool InProject;

        public static AppPaths Resolve(string exeDir)
        {
            string unpacked = Unpack();
            var p = new AppPaths { ExeDir = exeDir };
            p.InProject = File.Exists(Path.Combine(exeDir, @"scripts\build-wiivc.ps1"));
            if (p.InProject)
            {
                p.ScriptRoot = exeDir;
                p.Output = Path.Combine(exeDir, "output");
                p.Work = Path.Combine(exeDir, "work");
            }
            else if (unpacked != null)
            {
                p.ScriptRoot = unpacked;
                // Own names, because the build deletes its work folder: never reuse a
                // folder the player already has next to the exe.
                p.Output = Path.Combine(exeDir, "RetroPadU output");
                p.Work = Path.Combine(p.Output, "temp");
            }
            else return null;
            if (unpacked != null)
            {
                string wit = Path.Combine(unpacked, @"tools\wit\wit.exe");
                if (File.Exists(wit)) p.Wit = wit;
            }
            return p;
        }

        // Unpacks the embedded payload.zip into a folder named after its hash and
        // returns it, or null when the exe has no payload.
        static string Unpack()
        {
            using (Stream payload = typeof(AppPaths).Assembly.GetManifestResourceStream("payload.zip"))
            {
                if (payload == null) return null;
                string hash;
                using (var sha = System.Security.Cryptography.SHA256.Create())
                    hash = BitConverter.ToString(sha.ComputeHash(payload)).Replace("-", "").Substring(0, 16).ToLowerInvariant();
                string baseDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "RetroPadU");
                string dir = Path.Combine(baseDir, "files-" + hash);
                if (Directory.Exists(dir)) return dir;

                // Unpack beside it and rename, so a half-unpacked folder is never used.
                string temp = dir + ".unpacking-" + Process.GetCurrentProcess().Id;
                if (Directory.Exists(temp)) Directory.Delete(temp, true);
                payload.Position = 0;
                using (var zip = new System.IO.Compression.ZipArchive(payload, System.IO.Compression.ZipArchiveMode.Read))
                    System.IO.Compression.ZipFileExtensions.ExtractToDirectory(zip, temp);
                try { Directory.Move(temp, dir); }
                catch (IOException)
                {
                    // Another RetroPadU window unpacked it first.
                    if (!Directory.Exists(dir)) throw;
                    try { Directory.Delete(temp, true); } catch { }
                }
                return dir;
            }
        }
    }

    // ------------------------------------------------------------------ theme

    static class Theme
    {
        public static bool Dark;
        public static float Scale = 1f;
        public static Color Back, Card, Border, Text, Muted, Hover, Ring, Accent, AccentHover, AccentPressed,
            HeaderTop, HeaderBottom, ButtonBack, ButtonHover, ButtonPressed, InputBack, Success, Warn, Error,
            ConsoleBack, ConsoleText, ConsoleMuted, ConsoleAccent, ConsoleWarn, ConsoleError, ConsoleSuccess;
        public static Font Ui, UiBold, Title, Small, Big, Icon, IconSmall, Mono;

        public static void Init(float scale)
        {
            Scale = scale;
            Dark = ReadDarkMode();
            if (Dark)
            {
                Back = Rgb(0x1B1D21); Card = Rgb(0x25282D); Border = Rgb(0x373B42); Text = Rgb(0xECEEF2); Muted = Rgb(0x9AA1AD);
                Hover = Rgb(0x2D3137); Ring = Rgb(0x5A616C); InputBack = Rgb(0x1E2125);
                ButtonBack = Rgb(0x30343A); ButtonHover = Rgb(0x393E45); ButtonPressed = Rgb(0x42474F);
                Accent = Rgb(0x1C8DD0); AccentHover = Rgb(0x2E9DDC); AccentPressed = Rgb(0x1678B3);
                HeaderTop = Rgb(0x0B4F7E); HeaderBottom = Rgb(0x0E6EA6);
                Success = Rgb(0x3CC57A); Warn = Rgb(0xE0A33A); Error = Rgb(0xFF6B6B);
            }
            else
            {
                Back = Rgb(0xF2F4F7); Card = Rgb(0xFFFFFF); Border = Rgb(0xE0E3E9); Text = Rgb(0x1A1D23); Muted = Rgb(0x66707F);
                Hover = Rgb(0xF4F6F9); Ring = Rgb(0xC2C8D1); InputBack = Rgb(0xFFFFFF);
                ButtonBack = Rgb(0xFFFFFF); ButtonHover = Rgb(0xF0F3F7); ButtonPressed = Rgb(0xE4E8EE);
                Accent = Rgb(0x0A80CC); AccentHover = Rgb(0x0972B5); AccentPressed = Rgb(0x08629C);
                HeaderTop = Rgb(0x0B66A6); HeaderBottom = Rgb(0x1290D6);
                Success = Rgb(0x1E9A55); Warn = Rgb(0xB7791F); Error = Rgb(0xD13438);
            }
            ConsoleBack = Rgb(0x15171B); ConsoleText = Rgb(0xD3D8E0); ConsoleMuted = Rgb(0x7D8592);
            ConsoleAccent = Rgb(0x55B8F0); ConsoleWarn = Rgb(0xE8B04B); ConsoleError = Rgb(0xFF7B7B); ConsoleSuccess = Rgb(0x52D38D);

            Ui = new Font("Segoe UI", 9.5f);
            UiBold = new Font("Segoe UI Semibold", 9.75f);
            Title = new Font("Segoe UI Semibold", 11f);
            Small = new Font("Segoe UI", 8.25f);
            Big = new Font("Segoe UI Semibold", 10.5f);
            Icon = new Font("Segoe MDL2 Assets", 10f);
            IconSmall = new Font("Segoe MDL2 Assets", 8f);
            Mono = new Font("Consolas", 9.5f);
        }

        static bool ReadDarkMode()
        {
            try
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"))
                {
                    object value = key == null ? null : key.GetValue("AppsUseLightTheme");
                    return value is int && (int)value == 0;
                }
            }
            catch { return false; }
        }

        public static Color Rgb(int rgb) { return Color.FromArgb((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF); }
        public static int Px(float v) { return (int)Math.Round(v * Scale); }

        public static Color Blend(Color a, Color b, float t)
        {
            return Color.FromArgb((int)(a.R + (b.R - a.R) * t), (int)(a.G + (b.G - a.G) * t), (int)(a.B + (b.B - a.B) * t));
        }

        public static GraphicsPath Round(RectangleF r, float radius)
        {
            var path = new GraphicsPath();
            float d = Math.Min(radius * 2, Math.Min(r.Width, r.Height));
            if (d <= 0) { path.AddRectangle(r); return path; }
            path.AddArc(r.X, r.Y, d, d, 180, 90);
            path.AddArc(r.Right - d, r.Y, d, d, 270, 90);
            path.AddArc(r.Right - d, r.Bottom - d, d, d, 0, 90);
            path.AddArc(r.X, r.Bottom - d, d, d, 90, 90);
            path.CloseFigure();
            return path;
        }

        public static void Fill(Graphics g, RectangleF r, float radius, Color color)
        {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            using (GraphicsPath path = Round(r, radius))
            using (var brush = new SolidBrush(color)) g.FillPath(brush, path);
        }

        public static void Outline(Graphics g, RectangleF r, float radius, Color color, float width)
        {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            using (GraphicsPath path = Round(r, radius))
            using (var pen = new Pen(color, width)) g.DrawPath(pen, path);
        }

        public static Size Measure(string text, Font font)
        {
            return TextRenderer.MeasureText(text, font, new Size(int.MaxValue, int.MaxValue), TextFormatFlags.NoPadding | TextFormatFlags.NoPrefix);
        }

        public static void Draw(Graphics g, string text, Font font, Rectangle r, Color color, TextFormatFlags extra)
        {
            TextRenderer.DrawText(g, text, font, r, color,
                TextFormatFlags.NoPadding | TextFormatFlags.NoPrefix | TextFormatFlags.SingleLine | TextFormatFlags.VerticalCenter | extra);
        }

        // Parent background for the corners of rounded controls.
        public static Color BackOf(Control c)
        {
            for (Control p = c.Parent; p != null; p = p.Parent)
            {
                var row = p as FileRow;
                if (row != null) return row.CurrentBack;
                if (p is Card) return Theme.Card;
                if (p.BackColor.A == 255) return p.BackColor;
            }
            return Back;
        }
    }

    // The logo: the Wii U mark, a rounded rectangle with a U cut out of the top.
    static class Art
    {
        public static readonly Color LogoBlue = Theme.Rgb(0x03A9F4);

        // Fits the logo (1400 x 1000) into r. The U is a hole, so what is behind shows through.
        public static GraphicsPath Logo(RectangleF r)
        {
            float sx = r.Width / 1400f, sy = r.Height / 1000f;
            Func<float, float> X = v => r.X + v * sx;
            Func<float, float> Y = v => r.Y + v * sy;
            var path = new GraphicsPath(FillMode.Alternate);
            using (GraphicsPath box = Theme.Round(r, 170 * sx)) path.AddPath(box, false);
            path.StartFigure();
            path.AddLine(X(367), Y(0), X(367), Y(454));
            path.AddArc(X(367), Y(454 - 344), 666 * sx, 688 * sy, 180, -180);
            path.AddLine(X(1033), Y(454), X(1033), Y(0));
            path.AddLine(X(867), Y(0), X(867), Y(454));
            path.AddArc(X(533), Y(454 - 179), 334 * sx, 358 * sy, 0, 180);
            path.AddLine(X(533), Y(454), X(533), Y(0));
            path.CloseFigure();
            return path;
        }

        public static void DrawLogo(Graphics g, RectangleF r, Color color)
        {
            g.SmoothingMode = SmoothingMode.AntiAlias;
            using (GraphicsPath path = Logo(r))
            using (var brush = new SolidBrush(color)) g.FillPath(brush, path);
        }

        public static Bitmap AppIcon(int size)
        {
            var bmp = new Bitmap(size, size, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.Clear(Color.Transparent);
                float w = size, h = w / 1.4f;
                DrawLogo(g, new RectangleF(0, (size - h) / 2, w, h), LogoBlue);
            }
            return bmp;
        }

        // An .ico with PNG images, as Windows Vista and later read them.
        public static void WriteIcon(string path)
        {
            int[] sizes = { 16, 20, 24, 32, 40, 48, 64, 128, 256 };
            var images = new List<byte[]>();
            foreach (int size in sizes)
                using (Bitmap bmp = AppIcon(size))
                using (var ms = new MemoryStream()) { bmp.Save(ms, ImageFormat.Png); images.Add(ms.ToArray()); }
            using (var w = new BinaryWriter(File.Create(path)))
            {
                w.Write((short)0); w.Write((short)1); w.Write((short)sizes.Length);
                int offset = 6 + 16 * sizes.Length;
                for (int i = 0; i < sizes.Length; ++i)
                {
                    w.Write((byte)(sizes[i] >= 256 ? 0 : sizes[i])); w.Write((byte)(sizes[i] >= 256 ? 0 : sizes[i]));
                    w.Write((byte)0); w.Write((byte)0); w.Write((short)1); w.Write((short)32);
                    w.Write(images[i].Length); w.Write(offset);
                    offset += images[i].Length;
                }
                foreach (byte[] image in images) w.Write(image);
            }
        }
    }

    // --------------------------------------------------------------- controls

    class Card : Panel
    {
        bool highlight;
        public bool Highlight
        {
            get { return highlight; }
            set { if (highlight != value) { highlight = value; Invalidate(); } }
        }

        public Card()
        {
            SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw | ControlStyles.UserPaint, true);
            BackColor = Theme.Back;
            Padding = new Padding(Theme.Px(16));
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.Clear(Theme.Back);
            float inset = highlight ? 1f : 0.5f;
            var r = new RectangleF(inset, inset, Width - 1 - inset * 2, Height - 1 - inset * 2);
            Theme.Fill(g, r, Theme.Px(10), Theme.Card);
            Theme.Outline(g, r, Theme.Px(10), highlight ? Theme.Accent : Theme.Border, highlight ? 2f : 1f);
        }
    }

    // The dark box that holds the build log.
    class ConsolePanel : Panel
    {
        public ConsolePanel()
        {
            SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw | ControlStyles.UserPaint, true);
            BackColor = Theme.Card;
            Padding = new Padding(Theme.Px(12), Theme.Px(10), Theme.Px(4), Theme.Px(6));
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.Clear(Theme.Card);
            Theme.Fill(e.Graphics, new RectangleF(0, 0, Width - 1, Height - 1), Theme.Px(8), Theme.ConsoleBack);
        }
    }

    enum ButtonKind { Primary, Secondary, Ghost }

    class ModernButton : Button
    {
        public ButtonKind Kind;
        public string Glyph;
        bool hover, pressed;

        public ModernButton(string text, string glyph, ButtonKind kind, int height)
        {
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
            FlatStyle = FlatStyle.Flat;
            FlatAppearance.BorderSize = 0;
            Cursor = Cursors.Hand;
            Height = height;
            SetContent(text, glyph, kind);
        }

        public void SetContent(string text, string glyph, ButtonKind kind)
        {
            Text = text;
            Glyph = glyph;
            Kind = kind;
            Font = kind == ButtonKind.Primary ? Theme.Big : Theme.Ui;
            Invalidate();
        }

        public int ContentWidth()
        {
            int w = 0;
            if (!string.IsNullOrEmpty(Glyph)) w += Theme.Measure(Glyph, Theme.Icon).Width;
            if (!string.IsNullOrEmpty(Text)) w += (w > 0 ? Theme.Px(8) : 0) + Theme.Measure(Text, Font).Width;
            return w;
        }

        public void FitWidth()
        {
            Width = string.IsNullOrEmpty(Text) ? Height : ContentWidth() + Theme.Px(Kind == ButtonKind.Primary ? 40 : 28);
        }

        protected override void OnMouseEnter(EventArgs e) { hover = true; Invalidate(); base.OnMouseEnter(e); }
        protected override void OnMouseLeave(EventArgs e) { hover = pressed = false; Invalidate(); base.OnMouseLeave(e); }
        protected override void OnMouseDown(MouseEventArgs e) { if (e.Button == MouseButtons.Left) { pressed = true; Invalidate(); } base.OnMouseDown(e); }
        protected override void OnMouseUp(MouseEventArgs e) { pressed = false; Invalidate(); base.OnMouseUp(e); }
        protected override void OnEnabledChanged(EventArgs e) { hover = pressed = false; Invalidate(); base.OnEnabledChanged(e); }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            Color back = Theme.BackOf(this);
            g.Clear(back);
            Color fill, fore, border = Color.Empty;
            if (Kind == ButtonKind.Primary)
            {
                fill = !Enabled ? Theme.Blend(Theme.Accent, back, 0.55f) : pressed ? Theme.AccentPressed : hover ? Theme.AccentHover : Theme.Accent;
                fore = Enabled ? Color.White : Theme.Blend(Color.White, fill, 0.35f);
            }
            else if (Kind == ButtonKind.Secondary)
            {
                fill = !Enabled ? back : pressed ? Theme.ButtonPressed : hover ? Theme.ButtonHover : Theme.ButtonBack;
                border = Theme.Border;
                fore = Enabled ? Theme.Text : Theme.Muted;
            }
            else
            {
                fill = !Enabled ? back : pressed ? Theme.ButtonPressed : hover ? Theme.ButtonHover : back;
                fore = Enabled && hover ? Theme.Text : Theme.Muted;
            }
            var r = new RectangleF(0.5f, 0.5f, Width - 1.5f, Height - 1.5f);
            float radius = Theme.Px(6);
            Theme.Fill(g, r, radius, fill);
            if (border != Color.Empty) Theme.Outline(g, r, radius, border, 1f);
            if (Focused && ShowFocusCues) Theme.Outline(g, new RectangleF(1.5f, 1.5f, Width - 3.5f, Height - 3.5f), radius - 1, Theme.Accent, 2f);

            int x = (Width - ContentWidth()) / 2;
            if (!string.IsNullOrEmpty(Glyph))
            {
                int gw = Theme.Measure(Glyph, Theme.Icon).Width;
                Theme.Draw(g, Glyph, Theme.Icon, new Rectangle(x, 0, gw, Height), fore, TextFormatFlags.Default);
                x += gw + Theme.Px(8);
            }
            if (!string.IsNullOrEmpty(Text))
                Theme.Draw(g, Text, Font, new Rectangle(x, 0, Width - x, Height), fore, TextFormatFlags.Default);
        }
    }

    // One file to pick: a status circle, a title, the chosen file (or a hint), and Browse.
    class FileRow : Control
    {
        public readonly string Title, Hint;
        public readonly bool Optional;
        public readonly int Number;
        public bool Divider;
        public readonly ModernButton Browse, Clear;
        public string Value { get; private set; }
        string display;
        bool hover;

        public FileRow(string title, string hint, int number, bool optional)
        {
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
            SetStyle(ControlStyles.Selectable, false);
            Title = title; Hint = hint; Number = number; Optional = optional;
            Height = Theme.Px(58);
            BackColor = Theme.Card;
            Cursor = Cursors.Hand;
            Browse = new ModernButton("Browse", "", ButtonKind.Secondary, Theme.Px(32));
            Browse.FitWidth();
            Controls.Add(Browse);
            if (optional)
            {
                Clear = new ModernButton("", "", ButtonKind.Ghost, Theme.Px(32));
                Clear.FitWidth();
                Clear.Visible = false;
                Controls.Add(Clear);
            }
        }

        public Color CurrentBack { get { return hover && Enabled ? Theme.Hover : Theme.Card; } }

        public void SetValue(string path, string shortPath)
        {
            Value = path;
            display = shortPath;
            if (Clear != null) Clear.Visible = path != null;
            PerformLayout();
            Invalidate();
        }

        protected override void OnLayout(LayoutEventArgs e)
        {
            if (Browse == null) return;
            int right = Width - Theme.Px(10);
            Browse.Location = new Point(right - Browse.Width, (Height - Browse.Height) / 2);
            if (Clear != null) Clear.Location = new Point(Browse.Left - Theme.Px(4) - Clear.Width, (Height - Clear.Height) / 2);
        }

        void SetHover(bool value)
        {
            if (hover == value) return;
            hover = value;
            Invalidate(true);
        }

        protected override void OnMouseEnter(EventArgs e) { SetHover(true); base.OnMouseEnter(e); }
        protected override void OnMouseLeave(EventArgs e)
        {
            // Moving onto Browse/Clear still counts as hovering the row.
            if (!ClientRectangle.Contains(PointToClient(Cursor.Position))) SetHover(false);
            base.OnMouseLeave(e);
        }
        protected override void OnControlAdded(ControlEventArgs e)
        {
            e.Control.MouseLeave += delegate { if (!ClientRectangle.Contains(PointToClient(Cursor.Position))) SetHover(false); };
            base.OnControlAdded(e);
        }
        protected override void OnEnabledChanged(EventArgs e) { Invalidate(true); base.OnEnabledChanged(e); }
        protected override void OnClick(EventArgs e) { if (Enabled) Browse.PerformClick(); base.OnClick(e); }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.Clear(Theme.Card);
            if (Divider)
                using (var pen = new Pen(Theme.Border)) g.DrawLine(pen, Theme.Px(8), 0, Width - Theme.Px(8), 0);
            if (hover && Enabled) Theme.Fill(g, new RectangleF(0, Theme.Px(3), Width - 1, Height - Theme.Px(6)), Theme.Px(8), Theme.Hover);

            // Status circle: a check when chosen, the step number (or +) when not.
            int d = Theme.Px(30), cx = Theme.Px(10), cy = (Height - d) / 2;
            var circle = new RectangleF(cx, cy, d, d);
            g.SmoothingMode = SmoothingMode.AntiAlias;
            if (Value != null)
            {
                using (var brush = new SolidBrush(Enabled ? Theme.Success : Theme.Blend(Theme.Success, Theme.Card, 0.4f))) g.FillEllipse(brush, circle);
                Theme.Draw(g, "", Theme.Icon, Rectangle.Round(circle), Color.White, TextFormatFlags.HorizontalCenter);
            }
            else
            {
                using (var pen = new Pen(Theme.Ring, Theme.Px(1.5f)))
                {
                    if (Optional) pen.DashPattern = new[] { 2.5f, 2f };
                    g.DrawEllipse(pen, circle.X + 0.75f, circle.Y + 0.75f, circle.Width - 1.5f, circle.Height - 1.5f);
                }
                if (Optional) Theme.Draw(g, "", Theme.IconSmall, Rectangle.Round(circle), Theme.Muted, TextFormatFlags.HorizontalCenter);
                else Theme.Draw(g, Number.ToString(), Theme.UiBold, Rectangle.Round(circle), Theme.Muted, TextFormatFlags.HorizontalCenter);
            }

            int x = cx + d + Theme.Px(14);
            int right = (Clear != null && Clear.Visible ? Clear.Left : Browse.Left) - Theme.Px(12);
            int titleH = Theme.Measure("Ag", Theme.UiBold).Height, lineH = Theme.Measure("Ag", Theme.Ui).Height;
            int top = (Height - titleH - lineH - Theme.Px(2)) / 2;
            Color text = Enabled ? Theme.Text : Theme.Muted;

            int titleW = Math.Min(Theme.Measure(Title, Theme.UiBold).Width, right - x);
            Theme.Draw(g, Title, Theme.UiBold, new Rectangle(x, top, titleW, titleH), text, TextFormatFlags.EndEllipsis);
            if (Optional)
            {
                Size tag = Theme.Measure("optional", Theme.Small);
                var pill = new Rectangle(x + titleW + Theme.Px(8), top + (titleH - tag.Height - Theme.Px(2)) / 2, tag.Width + Theme.Px(12), tag.Height + Theme.Px(2));
                if (pill.Right < right)
                {
                    Theme.Outline(g, pill, pill.Height / 2f, Theme.Border, 1f);
                    Theme.Draw(g, "optional", Theme.Small, pill, Theme.Muted, TextFormatFlags.HorizontalCenter);
                }
            }

            int y = top + titleH + Theme.Px(2);
            if (Value == null)
            {
                Theme.Draw(g, Hint, Theme.Ui, new Rectangle(x, y, right - x, lineH), Theme.Muted, TextFormatFlags.EndEllipsis);
                return;
            }
            string name = Path.GetFileName(display);
            string folder = Path.GetDirectoryName(display) ?? "";
            int nameW = Math.Min(Theme.Measure(name, Theme.Ui).Width, right - x);
            Theme.Draw(g, name, Theme.Ui, new Rectangle(x, y, nameW, lineH), text, TextFormatFlags.EndEllipsis);
            int fx = x + nameW + Theme.Px(8);
            if (folder.Length > 0 && right - fx > Theme.Px(40))
                Theme.Draw(g, "in " + folder, Theme.Ui, new Rectangle(fx, y, right - fx, lineH), Theme.Muted, TextFormatFlags.PathEllipsis);
        }
    }

    // A text box with a rounded border that lights up when focused.
    class InputBox : Panel
    {
        public readonly TextBox Box;
        bool focused;

        public InputBox()
        {
            SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw | ControlStyles.UserPaint, true);
            BackColor = Theme.Card;
            Cursor = Cursors.IBeam;
            Box = new TextBox { BorderStyle = BorderStyle.None, BackColor = Theme.InputBack, ForeColor = Theme.Text, Font = Theme.Ui };
            Box.GotFocus += delegate { focused = true; Invalidate(); };
            Box.LostFocus += delegate { focused = false; Invalidate(); };
            Controls.Add(Box);
            Click += delegate { Box.Focus(); };
        }

        protected override void OnLayout(LayoutEventArgs e)
        {
            if (Box == null) return;
            int pad = Theme.Px(10);
            Box.SetBounds(pad, (Height - Box.Height) / 2, Width - pad * 2, Box.Height);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.Clear(Theme.Card);
            var r = new RectangleF(0.5f, 0.5f, Width - 1.5f, Height - 1.5f);
            Theme.Fill(g, r, Theme.Px(6), Theme.InputBack);
            if (focused) Theme.Outline(g, new RectangleF(1, 1, Width - 2.5f, Height - 2.5f), Theme.Px(6), Theme.Accent, 2f);
            else Theme.Outline(g, r, Theme.Px(6), Theme.Border, 1f);
        }
    }

    class ToggleSwitch : CheckBox
    {
        bool hover;

        public ToggleSwitch(string text)
        {
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
            AutoSize = false;
            Cursor = Cursors.Hand;
            Font = Theme.Ui;
            Text = text;
            Width = Theme.Px(40 + 10) + Theme.Measure(text, Theme.Ui).Width + Theme.Px(4);
        }

        protected override void OnCheckedChanged(EventArgs e) { Invalidate(); base.OnCheckedChanged(e); }
        protected override void OnEnabledChanged(EventArgs e) { Invalidate(); base.OnEnabledChanged(e); }
        protected override void OnMouseEnter(EventArgs e) { hover = true; Invalidate(); base.OnMouseEnter(e); }
        protected override void OnMouseLeave(EventArgs e) { hover = false; Invalidate(); base.OnMouseLeave(e); }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.Clear(Theme.BackOf(this));
            int tw = Theme.Px(40), th = Theme.Px(22);
            var track = new RectangleF(1, (Height - th) / 2f, tw, th);
            Color on = hover ? Theme.AccentHover : Theme.Accent;
            Color off = Theme.Dark ? Theme.Rgb(0x4A4F57) : Theme.Rgb(0xC9CED6);
            Color fill = Checked ? on : off;
            if (!Enabled) fill = Theme.Blend(fill, Theme.Card, 0.5f);
            Theme.Fill(g, track, th / 2f, fill);
            if (Focused && ShowFocusCues) Theme.Outline(g, RectangleF.Inflate(track, 2, 2), th / 2f + 2, Theme.Accent, 1.5f);
            float k = th - Theme.Px(6);
            float kx = Checked ? track.Right - Theme.Px(3) - k : track.X + Theme.Px(3);
            using (var brush = new SolidBrush(Color.White)) g.FillEllipse(brush, kx, track.Y + Theme.Px(3), k, k);
            int x = (int)track.Right + Theme.Px(10);
            Theme.Draw(g, Text, Font, new Rectangle(x, 0, Width - x, Height), Enabled ? Theme.Text : Theme.Muted, TextFormatFlags.Default);
        }
    }

    // A thin progress bar that eases toward its value, with a moving sheen while running.
    class SlimProgress : Control
    {
        float target, shown, phase;
        bool running;
        Color fill = Theme.Accent;
        readonly System.Windows.Forms.Timer timer = new System.Windows.Forms.Timer { Interval = 16 };

        public SlimProgress()
        {
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
            SetStyle(ControlStyles.Selectable, false);
            Height = Theme.Px(6);
            timer.Tick += delegate
            {
                shown += (target - shown) * 0.08f;
                if (Math.Abs(target - shown) < 0.0005f) shown = target;
                phase = (phase + 0.008f) % 1.4f;
                Invalidate();
                if (!running && shown == target) timer.Stop();
            };
        }

        public float Value
        {
            get { return target; }
            set { target = Math.Max(0, Math.Min(1, value)); timer.Start(); }
        }

        public bool Running
        {
            get { return running; }
            set { running = value; timer.Start(); }
        }

        public Color FillColor { set { fill = value; Invalidate(); } }

        public void Reset() { target = shown = 0; Invalidate(); }

        protected override void Dispose(bool disposing)
        {
            if (disposing) timer.Dispose();
            base.Dispose(disposing);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.Clear(Theme.BackOf(this));
            var track = new RectangleF(0, 0, Width - 1, Height - 1);
            Theme.Fill(g, track, Height / 2f, Theme.Dark ? Theme.Rgb(0x30343A) : Theme.Rgb(0xDDE2E8));
            float w = Math.Max(shown > 0 ? Height : 0, (Width - 1) * shown);
            if (w <= 0) return;
            var bar = new RectangleF(0, 0, w, Height - 1);
            Theme.Fill(g, bar, Height / 2f, fill);
            if (!running) return;
            float sheen = Width * 0.18f, sx = (phase - 0.2f) * Width;
            var clip = g.Clip;
            using (GraphicsPath path = Theme.Round(bar, Height / 2f))
            {
                g.SetClip(path);
                var rect = new RectangleF(sx, 0, sheen, Height);
                using (var brush = new LinearGradientBrush(new RectangleF(sx - 1, 0, sheen + 2, Height), Color.FromArgb(0, Color.White), Color.FromArgb(0, Color.White), 0f))
                {
                    var blend = new ColorBlend
                    {
                        Colors = new[] { Color.FromArgb(0, Color.White), Color.FromArgb(90, Color.White), Color.FromArgb(0, Color.White) },
                        Positions = new[] { 0f, 0.5f, 1f },
                    };
                    brush.InterpolationColors = blend;
                    g.FillRectangle(brush, rect);
                }
            }
            g.Clip = clip;
        }
    }

    enum StatusKind { Idle, Ready, Busy, Success, Warn, Error }

    // The status line above the progress bar: an icon, a title and a muted detail.
    class StatusLine : Control
    {
        StatusKind kind;
        string title = "", detail = "";

        public StatusLine()
        {
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
            SetStyle(ControlStyles.Selectable, false);
            Height = Theme.Px(26);
        }

        public StatusKind Kind { get { return kind; } }

        public void Set(StatusKind kind, string title, string detail)
        {
            this.kind = kind;
            this.title = title ?? "";
            this.detail = detail ?? "";
            Invalidate();
        }

        public string Detail
        {
            get { return detail; }
            set { detail = value ?? ""; Invalidate(); }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            g.Clear(Theme.BackOf(this));
            g.SmoothingMode = SmoothingMode.AntiAlias;
            int d = Theme.Px(18), y = (Height - d) / 2;
            var circle = new Rectangle(0, y, d, d);
            Color color;
            string glyph = null;
            switch (kind)
            {
                case StatusKind.Success: color = Theme.Success; glyph = ""; break;
                case StatusKind.Error: color = Theme.Error; glyph = ""; break;
                case StatusKind.Warn: color = Theme.Warn; glyph = ""; break;
                case StatusKind.Busy: color = Theme.Accent; break;
                case StatusKind.Ready: color = Theme.Accent; break;
                default: color = Theme.Ring; break;
            }
            if (glyph != null)
            {
                using (var brush = new SolidBrush(color)) g.FillEllipse(brush, circle);
                Theme.Draw(g, glyph, Theme.IconSmall, circle, Color.White, TextFormatFlags.HorizontalCenter);
            }
            else
            {
                int dot = Theme.Px(10);
                using (var brush = new SolidBrush(color)) g.FillEllipse(brush, (d - dot) / 2f, (Height - dot) / 2f, dot, dot);
                if (kind == StatusKind.Busy)
                    using (var pen = new Pen(Color.FromArgb(70, color), Theme.Px(2))) g.DrawEllipse(pen, 1, y + 1, d - 2, d - 2);
            }
            int x = d + Theme.Px(10);
            int tw = Math.Min(Theme.Measure(title, Theme.UiBold).Width, Width - x);
            Theme.Draw(g, title, Theme.UiBold, new Rectangle(x, 0, tw, Height), Theme.Text, TextFormatFlags.EndEllipsis);
            int dx = x + tw + Theme.Px(10);
            if (detail.Length > 0 && Width - dx > Theme.Px(30))
                Theme.Draw(g, detail, Theme.Ui, new Rectangle(dx, 0, Width - dx, Height), Theme.Muted, TextFormatFlags.EndEllipsis);
        }
    }

    // The coloured band at the top: logo, name, and whether wit is installed.
    class Header : Control
    {
        bool witOk = true;
        Rectangle chip;
        public event EventHandler ChipClicked;

        public Header()
        {
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
            SetStyle(ControlStyles.Selectable, false);
            Height = Theme.Px(88);
        }

        string witText = "";

        public void SetWit(bool ok, string text)
        {
            witOk = ok;
            witText = text;
            Invalidate();
        }

        protected override void OnMouseMove(MouseEventArgs e)
        {
            Cursor = !witOk && chip.Contains(e.Location) ? Cursors.Hand : Cursors.Default;
            base.OnMouseMove(e);
        }

        protected override void OnMouseClick(MouseEventArgs e)
        {
            if (!witOk && chip.Contains(e.Location) && ChipClicked != null) ChipClicked(this, EventArgs.Empty);
            base.OnMouseClick(e);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            Graphics g = e.Graphics;
            var all = new Rectangle(0, 0, Width, Height);
            using (var brush = new LinearGradientBrush(new Rectangle(0, -1, Width, Height + 2), Theme.HeaderTop, Theme.HeaderBottom, 90f))
                g.FillRectangle(brush, all);
            g.SmoothingMode = SmoothingMode.AntiAlias;
            using (var brush = new SolidBrush(Color.FromArgb(16, Color.White)))
            {
                g.FillEllipse(brush, Width - Theme.Px(300), -Theme.Px(120), Theme.Px(240), Theme.Px(240));
                g.FillEllipse(brush, Width - Theme.Px(150), Theme.Px(10), Theme.Px(190), Theme.Px(190));
            }

            int pad = Theme.Px(24);
            float pw = Theme.Px(52), ph = Theme.Px(52 / 1.4f);
            Art.DrawLogo(g, new RectangleF(pad, (Height - ph) / 2f, pw, ph), Color.White);

            int x = pad + (int)pw + Theme.Px(16);
            using (var titleFont = new Font("Segoe UI Semibold", 17f))
            {
                int th = Theme.Measure("RetroPadU", titleFont).Height;
                int sh = Theme.Measure("Ag", Theme.Ui).Height;
                int top = (Height - th - sh) / 2;
                Theme.Draw(g, "RetroPadU", titleFont, new Rectangle(x, top, Width, th), Color.White, TextFormatFlags.Default);
                Theme.Draw(g, "Retro Rewind for the Wii U, as a Virtual Console inject", Theme.Ui,
                    new Rectangle(x, top + th, Width, sh), Theme.Blend(Color.White, Theme.HeaderBottom, 0.22f), TextFormatFlags.Default);
            }

            string text = witText;
            string glyph = witOk ? "" : "";
            Size ts = Theme.Measure(text, Theme.Ui), gs = Theme.Measure(glyph, Theme.IconSmall);
            int cw = ts.Width + gs.Width + Theme.Px(30), ch = Theme.Px(30);
            chip = new Rectangle(Width - pad - cw, (Height - ch) / 2, cw, ch);
            if (chip.Left < x + Theme.Px(330)) { chip = Rectangle.Empty; return; }
            Color chipFill = witOk ? Theme.Blend(Theme.HeaderBottom, Color.White, 0.16f) : Theme.Rgb(0xFFC94D);
            Color chipText = witOk ? Color.White : Theme.Rgb(0x3D2C00);
            Theme.Fill(g, chip, ch / 2f, chipFill);
            int cx = chip.X + Theme.Px(12);
            Theme.Draw(g, glyph, Theme.IconSmall, new Rectangle(cx, chip.Y, gs.Width, ch), witOk ? Theme.Rgb(0x8BF0B5) : chipText, TextFormatFlags.Default);
            Theme.Draw(g, text, Theme.Ui, new Rectangle(cx + gs.Width + Theme.Px(6), chip.Y, ts.Width + 2, ch), chipText, TextFormatFlags.Default);
        }
    }

    // ---------------------------------------------------------------- window

    class MainForm : Form
    {
        const string DefaultName = "Mario Kart Retro Rewind WiiVC";
        static readonly string[] ImageExtensions = { ".iso", ".wbfs", ".wdf", ".wia", ".ciso" };

        // The script's "==>" steps, with where each one sits on the progress bar.
        // Extracting, packing and verifying also report wit's own percentage.
        class Step
        {
            public string Prefix, Label;
            public float Start, End;
            public bool Wit;
            public Step(string prefix, string label, float start, float end, bool wit) { Prefix = prefix; Label = label; Start = start; End = end; Wit = wit; }
        }
        static readonly Step[] Steps =
        {
            new Step("Checking requirements", "Checking your files", 0f, 0.02f, false),
            new Step("Rebuilding the bootstrap", "Rebuilding the loader", 0.02f, 0.02f, false),
            new Step("Extracting Mario Kart Wii", "Extracting Mario Kart Wii", 0.02f, 0.16f, true),
            new Step("Adding Retro Rewind files", "Adding Retro Rewind", 0.16f, 0.30f, false),
            new Step("Applying the pack", "Applying the pack's file list", 0.30f, 0.38f, false),
            new Step("Adding My Stuff", "Adding My Stuff", 0.38f, 0.41f, false),
            new Step("Installing the WiiVC bootstrap", "Installing the loader", 0.41f, 0.42f, false),
            new Step("Packing your save", "Packing your save", 0.42f, 0.43f, false),
            new Step("Packing the WBFS", "Packing the WBFS", 0.43f, 0.84f, true),
            new Step("Verifying", "Verifying the image", 0.84f, 0.97f, true),
            new Step("Preparing the SD card", "Preparing the SD card files", 0.97f, 0.99f, false),
        };
        static readonly Regex Percent = new Regex(@"(\d{1,3})%");

        readonly AppPaths paths;
        readonly string root;   // the folder RetroPadU.exe is in
        readonly string settingsPath;
        readonly Regex rootPrefix, homePrefix;

        Header header;
        Card filesCard;
        FileRow image, pack, rksys, rating;
        InputBox nameBox;
        ToggleSwitch myStuff;
        ModernButton build, openOutput, copyLog;
        StatusLine status;
        SlimProgress progress;
        RichTextBox log;
        ToolTip tips;
        System.Windows.Forms.Timer ticker;

        Process proc;
        bool stopping, resultShown;
        bool crPending;
        int lineStart;
        readonly StringBuilder currentLine = new StringBuilder();
        Step currentStep;
        Stopwatch elapsed = new Stopwatch();
        string failure;

        public MainForm(AppPaths paths)
        {
            this.paths = paths;
            root = paths.ExeDir;
            string home = (Environment.GetEnvironmentVariable("USERPROFILE") ?? "").TrimEnd('\\');
            rootPrefix = PathPattern(root, @"[\\/]");
            homePrefix = home.Length > 3 ? PathPattern(home, @"(?=[\\/])") : null;
            settingsPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), @"RetroPadU\settings.ini");

            Text = "RetroPadU";
            Font = Theme.Ui;
            BackColor = Theme.Back;
            ForeColor = Theme.Text;
            AutoScaleMode = AutoScaleMode.None;
            StartPosition = FormStartPosition.CenterScreen;
            Rectangle work = Screen.PrimaryScreen.WorkingArea;
            ClientSize = new Size(Math.Min(Theme.Px(840), work.Width - 40), Math.Min(Theme.Px(800), work.Height - 60));
            MinimumSize = new Size(Math.Min(Theme.Px(660), work.Width), Math.Min(Theme.Px(640), work.Height));
            try { Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath); } catch { }
            tips = new ToolTip();

            BuildLayout();
            HookDrop(this);
            LoadSettings();
            if (paths.Wit != null) header.SetWit(true, "Wiimms ISO Tools included");
            else if (FindWit() != null) header.SetWit(true, "Wiimms ISO Tools found");
            else header.SetWit(false, "Install Wiimms ISO Tools");
            UpdateState();
            AppendLog("Pick your files, then press Build. The build log appears here.\n", Theme.ConsoleMuted);
        }

        static int Px(float v) { return Theme.Px(v); }

        // ---------------------------------------------------------------- layout

        // Docks the controls top to bottom in the given order, with fill last.
        static void Stack(Control parent, Control fill, params Control[] tops)
        {
            if (fill != null) { fill.Dock = DockStyle.Fill; parent.Controls.Add(fill); }
            for (int i = tops.Length - 1; i >= 0; --i)
            {
                tops[i].Dock = DockStyle.Top;
                parent.Controls.Add(tops[i]);
            }
        }

        static Control Gap(int size) { return new Panel { Size = new Size(Px(size), Px(size)), BackColor = Color.Transparent }; }

        static Label MakeLabel(string text, Font font, Color color, Color back)
        {
            return new Label { Text = text, Font = font, ForeColor = color, BackColor = back, AutoSize = false, TextAlign = ContentAlignment.MiddleLeft, UseMnemonic = false };
        }

        void BuildLayout()
        {
            header = new Header();
            header.ChipClicked += delegate { OpenUrl("https://wit.wiimm.de"); };

            // Files
            filesCard = new Card { Padding = new Padding(Px(16), Px(12), Px(16), Px(8)) };
            var filesHead = new Panel { Height = Px(34), BackColor = Theme.Card };
            var filesTitle = MakeLabel("Your files", Theme.Title, Theme.Text, Theme.Card);
            filesTitle.Width = Theme.Measure("Your files", Theme.Title).Width + Px(12);
            var dropHint = MakeLabel("You can also drop files anywhere on this window", Theme.Small, Theme.Muted, Theme.Card);
            dropHint.TextAlign = ContentAlignment.MiddleRight;
            filesTitle.Dock = DockStyle.Left;
            dropHint.Dock = DockStyle.Fill;
            filesHead.Controls.Add(dropHint);
            filesHead.Controls.Add(filesTitle);

            image = new FileRow("Mario Kart Wii disc", "USA version (RMCE01): .iso, .wbfs, .wdf, .wia or .ciso", 1, false);
            pack = new FileRow("Retro Rewind pack", "The RetroRewind6 folder from rwfc.net/downloads, or the folder you extracted", 2, false);
            rksys = new FileRow("Save", @"rksys.dat, on your SD card in riivolution\save\RetroWFC\RMCE", 0, true);
            rating = new FileRow("VR", @"RRRating.pul, on your SD card in RetroRewind6", 0, true);
            pack.Divider = rksys.Divider = rating.Divider = true;
            image.Browse.Click += delegate { BrowseImage(); };
            pack.Browse.Click += delegate { BrowsePack(); };
            rksys.Browse.Click += delegate { BrowseFile(rksys, "Mario Kart Wii save (rksys.dat)|rksys.dat|All files|*.*"); };
            rating.Browse.Click += delegate { BrowseFile(rating, "Retro Rewind VR (RRRating.pul)|RRRating.pul|All files|*.*"); };
            rksys.Clear.Click += delegate { SetField(rksys, null); };
            rating.Clear.Click += delegate { SetField(rating, null); };
            foreach (FileRow row in new[] { rksys, rating }) tips.SetToolTip(row.Clear, "Don't import this file");
            Stack(filesCard, null, filesHead, image, pack, rksys, rating);
            filesCard.Height = Px(12 + 34 + 8) + image.Height * 4;

            // Options
            var optionsCard = new Card { Padding = new Padding(Px(16), Px(14), Px(16), Px(14)) };
            var nameLabel = MakeLabel("Disc name", Theme.UiBold, Theme.Text, Theme.Card);
            nameLabel.Width = Theme.Measure("Disc name", Theme.UiBold).Width + Px(16);
            nameLabel.Dock = DockStyle.Left;
            nameBox = new InputBox { Dock = DockStyle.Fill };
            nameBox.Box.Text = DefaultName;
            myStuff = new ToggleSwitch("Include My Stuff") { Checked = true, Dock = DockStyle.Right, BackColor = Theme.Card };
            tips.SetToolTip(myStuff, @"Builds in your custom fonts, HUD and music from RetroRewind6\MyStuff or input\MyStuff.");
            optionsCard.Controls.Add(nameBox);
            optionsCard.Controls.Add(Gap(18));
            optionsCard.Controls[1].Dock = DockStyle.Right;
            optionsCard.Controls[1].BackColor = Theme.Card;
            optionsCard.Controls.Add(myStuff);
            optionsCard.Controls.Add(nameLabel);
            optionsCard.Height = Px(14 + 36 + 14);

            // Status, progress and Build
            var bar = new Panel { Height = Px(60), BackColor = Theme.Back, Padding = new Padding(Px(2), Px(6), 0, Px(6)) };
            build = new ModernButton("Build", "", ButtonKind.Primary, Px(48)) { Dock = DockStyle.Right, Width = Px(150) };
            build.Click += delegate { if (IsBuilding) StopBuild(false); else StartBuild(); };
            openOutput = new ModernButton("Output folder", "", ButtonKind.Secondary, Px(48)) { Dock = DockStyle.Right };
            openOutput.FitWidth();
            openOutput.Click += delegate { OpenOutput(); };
            tips.SetToolTip(openOutput, "Open the folder with the finished WBFS");
            var statusArea = new Panel { BackColor = Theme.Back, Padding = new Padding(0, Px(4), Px(20), 0) };
            status = new StatusLine();
            progress = new SlimProgress();
            Stack(statusArea, null, status, Gap(8), progress);
            bar.Controls.Add(statusArea);
            statusArea.Dock = DockStyle.Fill;
            bar.Controls.Add(openOutput);
            var buttonGap = Gap(10);
            buttonGap.Dock = DockStyle.Right;
            bar.Controls.Add(buttonGap);
            bar.Controls.Add(build);
            AcceptButton = build;

            // Log
            var logCard = new Card { Padding = new Padding(Px(16), Px(10), Px(16), Px(16)) };
            var logHead = new Panel { Height = Px(40), BackColor = Theme.Card, Padding = new Padding(0, 0, 0, Px(8)) };
            var logTitle = MakeLabel("Build log", Theme.Title, Theme.Text, Theme.Card);
            logTitle.Dock = DockStyle.Fill;
            copyLog = new ModernButton("Copy", "", ButtonKind.Ghost, Px(32)) { Dock = DockStyle.Right };
            copyLog.FitWidth();
            copyLog.Click += delegate { CopyLog(); };
            tips.SetToolTip(copyLog, "Copy the build log");
            logHead.Controls.Add(logTitle);
            logHead.Controls.Add(copyLog);
            var console = new ConsolePanel();
            log = new RichTextBox
            {
                ReadOnly = true, BorderStyle = BorderStyle.None, BackColor = Theme.ConsoleBack, ForeColor = Theme.ConsoleText,
                Font = Theme.Mono, WordWrap = true, ScrollBars = RichTextBoxScrollBars.Vertical, DetectUrls = false, Dock = DockStyle.Fill,
            };
            log.HandleCreated += delegate { NativeMethods.SetWindowTheme(log.Handle, "DarkMode_Explorer", null); };
            log.GotFocus += delegate { NativeMethods.HideCaret(log.Handle); };
            log.MouseUp += delegate { NativeMethods.HideCaret(log.Handle); };
            console.Controls.Add(log);
            Stack(logCard, console, logHead);

            var body = new Panel { BackColor = Theme.Back, Padding = new Padding(Px(20), Px(18), Px(20), Px(20)) };
            Stack(body, logCard, filesCard, Gap(12), optionsCard, Gap(10), bar, Gap(10));
            Stack(this, body, header);
            ActiveControl = build;
        }

        void HookDrop(Control c)
        {
            c.AllowDrop = true;
            c.DragEnter += OnDragEnter;
            c.DragLeave += delegate { filesCard.Highlight = false; };
            c.DragDrop += OnDragDrop;
            foreach (Control child in c.Controls) HookDrop(child);
        }

        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            // Windows 11: colour the title bar like the header (white caption buttons).
            NativeMethods.SetDwm(Handle, 20, 1);
            NativeMethods.SetDwm(Handle, 35, ColorRef(Theme.HeaderTop));
            NativeMethods.SetDwm(Handle, 36, ColorRef(Color.White));
        }

        static int ColorRef(Color c) { return c.R | (c.G << 8) | (c.B << 16); }

        // ------------------------------------------------------------- choosing

        void SetField(FileRow row, string path)
        {
            row.SetValue(path, path == null ? null : ShortPath(path));
            resultShown = false;
            UpdateState();
        }

        void BrowseImage()
        {
            using (var dlg = new OpenFileDialog())
            {
                dlg.Title = "Mario Kart Wii (USA) disc image";
                dlg.Filter = "Wii disc images (*.iso, *.wbfs, *.wdf, *.wia, *.ciso)|*.iso;*.wbfs;*.wdf;*.wia;*.ciso|All files|*.*";
                SetInitialDir(dlg, image.Value);
                if (dlg.ShowDialog(this) == DialogResult.OK) SetImage(dlg.FileName);
            }
        }

        void BrowsePack()
        {
            string start = pack.Value ?? Path.Combine(root, "input");
            string dir = FolderPicker.Pick(this, "Retro Rewind pack (the RetroRewind6 folder, or the folder you extracted)", start);
            if (dir != null) SetPack(dir);
        }

        void BrowseFile(FileRow row, string filter)
        {
            using (var dlg = new OpenFileDialog())
            {
                dlg.Filter = filter;
                SetInitialDir(dlg, row.Value);
                if (dlg.ShowDialog(this) == DialogResult.OK) SetSaveFile(dlg.FileName);
            }
        }

        static void SetInitialDir(FileDialog dlg, string current)
        {
            if (current != null) dlg.InitialDirectory = Path.GetDirectoryName(current);
        }

        bool SetImage(string path)
        {
            string ext = Path.GetExtension(path).ToLowerInvariant();
            string name = Path.GetFileName(path).ToLowerInvariant();
            if (ext == ".rvz" || ext == ".nkit" || ext == ".gcz" || name.Contains(".nkit."))
            {
                MessageBox.Show(this, Path.GetFileName(path) + " is not supported by wit.\n\nIn Dolphin, right-click the game > Convert File... > ISO, then pick the .iso.",
                    "RetroPadU", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return false;
            }
            if (Array.IndexOf(ImageExtensions, ext) < 0) return false;
            SetField(image, path);
            return true;
        }

        bool SetPack(string dir)
        {
            string found = FindPack(dir);
            if (found == null)
            {
                MessageBox.Show(this, "No Retro Rewind pack in that folder.\n\nPick the RetroRewind6 folder (it contains Binaries\\Code.pul), or the folder you extracted the pack to.",
                    "RetroPadU", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return false;
            }
            SetField(pack, found);
            return true;
        }

        bool SetSaveFile(string path)
        {
            string name = Path.GetFileName(path).ToLowerInvariant();
            if (name == "rksys.dat") SetField(rksys, path);
            else if (name == "rrrating.pul") SetField(rating, path);
            else if (name == "banner.bin")
            {
                string sibling = Path.Combine(Path.GetDirectoryName(path), "rksys.dat");
                if (!File.Exists(sibling)) return false;
                SetField(rksys, sibling);
            }
            else
            {
                MessageBox.Show(this, "Pick rksys.dat (your save) or RRRating.pul (your VR).", "RetroPadU", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return false;
            }
            return true;
        }

        // The pack folder itself, or a RetroRewind6 folder up to two levels below it
        // (the same places the build script looks in input).
        static string FindPack(string dir)
        {
            if (File.Exists(Path.Combine(dir, @"Binaries\Code.pul"))) return dir;
            foreach (string candidate in FindDirs(dir, "RetroRewind6", 3))
                if (File.Exists(Path.Combine(candidate, @"Binaries\Code.pul"))) return candidate;
            return null;
        }

        static IEnumerable<string> FindDirs(string dir, string name, int depth)
        {
            if (depth == 0 || !Directory.Exists(dir)) yield break;
            string[] subs;
            try { subs = Directory.GetDirectories(dir); } catch { yield break; }
            foreach (string sub in subs)
            {
                if (string.Equals(Path.GetFileName(sub), name, StringComparison.OrdinalIgnoreCase)) yield return sub;
                foreach (string deeper in FindDirs(sub, name, depth - 1)) yield return deeper;
            }
        }

        void OnDragEnter(object sender, DragEventArgs e)
        {
            bool ok = !IsBuilding && e.Data.GetDataPresent(DataFormats.FileDrop);
            e.Effect = ok ? DragDropEffects.Copy : DragDropEffects.None;
            filesCard.Highlight = ok;
        }

        void OnDragDrop(object sender, DragEventArgs e)
        {
            filesCard.Highlight = false;
            var paths = e.Data.GetData(DataFormats.FileDrop) as string[];
            if (paths == null || IsBuilding) return;
            var ignored = new List<string>();
            foreach (string path in paths)
            {
                bool used;
                if (Directory.Exists(path)) used = FindPack(path) != null ? SetPack(path) : AddSaveFolder(path);
                else
                {
                    string name = Path.GetFileName(path).ToLowerInvariant();
                    used = name == "rksys.dat" || name == "rrrating.pul" || name == "banner.bin" ? SetSaveFile(path) : SetImage(path);
                }
                if (!used) ignored.Add(Path.GetFileName(path));
            }
            if (ignored.Count > 0)
                MessageBox.Show(this, "Not used:\n  " + string.Join("\n  ", ignored) +
                    "\n\nDrop a Mario Kart Wii disc image, the RetroRewind6 folder, rksys.dat or RRRating.pul.",
                    "RetroPadU", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        // A dropped folder that holds save files (like input\save).
        bool AddSaveFolder(string dir)
        {
            bool any = false;
            foreach (string name in new[] { "rksys.dat", "RRRating.pul" })
            {
                string[] hits;
                try { hits = Directory.GetFiles(dir, name, SearchOption.AllDirectories); } catch { continue; }
                if (hits.Length == 1) { SetSaveFile(hits[0]); any = true; }
            }
            return any;
        }

        // ------------------------------------------------------------- settings

        void LoadSettings()
        {
            var s = new Dictionary<string, string>();
            try
            {
                foreach (string line in File.ReadAllLines(settingsPath, Encoding.UTF8))
                {
                    int eq = line.IndexOf('=');
                    if (eq > 0) s[line.Substring(0, eq)] = line.Substring(eq + 1);
                }
            }
            catch { }

            string v;
            if (s.TryGetValue("image", out v) && File.Exists(v)) SetField(image, v);
            if (s.TryGetValue("pack", out v) && File.Exists(Path.Combine(v, @"Binaries\Code.pul"))) SetField(pack, v);
            if (s.TryGetValue("rksys", out v) && File.Exists(v)) SetField(rksys, v);
            if (s.TryGetValue("rating", out v) && File.Exists(v)) SetField(rating, v);
            if (s.TryGetValue("name", out v) && v.Trim().Length > 0) nameBox.Box.Text = v;
            if (s.TryGetValue("mystuff", out v)) myStuff.Checked = v != "0";

            // Fill the rest from the input folder, as BUILD.cmd would. Saves only on
            // the first run, so a save the player cleared is not picked up again.
            string input = Path.Combine(root, "input");
            if (image.Value == null && Directory.Exists(input))
            {
                var images = new List<string>();
                foreach (string f in Directory.GetFiles(input))
                    if (Array.IndexOf(ImageExtensions, Path.GetExtension(f).ToLowerInvariant()) >= 0 && !f.ToLowerInvariant().Contains(".nkit.")) images.Add(f);
                if (images.Count == 1) SetField(image, images[0]);
            }
            if (pack.Value == null)
            {
                string found = FindPack(input);
                if (found != null) SetField(pack, found);
            }
            if (s.Count == 0) AddSaveFolder(Path.Combine(input, "save"));
        }

        void SaveSettings()
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(settingsPath));
                File.WriteAllLines(settingsPath, new[]
                {
                    "image=" + image.Value, "pack=" + pack.Value, "rksys=" + rksys.Value, "rating=" + rating.Value,
                    "name=" + nameBox.Box.Text, "mystuff=" + (myStuff.Checked ? "1" : "0"),
                }, Encoding.UTF8);
            }
            catch { }
        }

        // ---------------------------------------------------------------- build

        bool IsBuilding { get { return proc != null; } }

        void UpdateState()
        {
            bool building = IsBuilding;
            foreach (FileRow row in new[] { image, pack, rksys, rating }) row.Enabled = !building;
            nameBox.Box.ReadOnly = building;
            myStuff.Enabled = !building;
            AcceptButton = building ? null : build;
            if (building)
            {
                build.SetContent(stopping ? "Stopping" : "Stop", "", ButtonKind.Secondary);
                build.Enabled = !stopping;
                return;
            }
            build.SetContent("Build", "", ButtonKind.Primary);
            bool ready = image.Value != null && pack.Value != null;
            build.Enabled = ready;
            if (resultShown) return;
            progress.Reset();
            if (ready) status.Set(StatusKind.Ready, "Ready to build", "takes a few minutes");
            else status.Set(StatusKind.Idle, image.Value == null ? "Pick your Mario Kart Wii disc" : "Pick the Retro Rewind pack", "");
        }

        void StartBuild()
        {
            if (IsBuilding || image.Value == null || pack.Value == null) return;
            if (FindWit() == null && MessageBox.Show(this, "Wiimms ISO Tools (wit) was not found, so the build will fail. Build anyway?",
                    "RetroPadU", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) != DialogResult.Yes) return;
            SaveSettings();

            var args = new List<string>
            {
                "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", Path.Combine(paths.ScriptRoot, @"scripts\build-wiivc.ps1"),
                "-Image", image.Value, "-Pack", pack.Value, "-Output", paths.Output, "-Work", paths.Work,
            };
            if (paths.Wit != null) { args.Add("-WitPath"); args.Add(paths.Wit); }
            string name = nameBox.Box.Text.Trim();
            if (name.Length > 0 && name != DefaultName) { args.Add("-Name"); args.Add(name); }
            if (rksys.Value == null && rating.Value == null) args.Add("-NoSave");
            if (rksys.Value != null) { args.Add("-Rksys"); args.Add(rksys.Value); }
            if (rating.Value != null) { args.Add("-Rating"); args.Add(rating.Value); }
            if (!myStuff.Checked) args.Add("-NoMyStuff");

            var psi = new ProcessStartInfo
            {
                FileName = Path.Combine(Environment.SystemDirectory, @"WindowsPowerShell\v1.0\powershell.exe"),
                Arguments = string.Join(" ", args.ConvertAll<string>(QuoteArg)),
                WorkingDirectory = root,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
            };
            // A PSModulePath inherited from PowerShell 7 makes Windows PowerShell load
            // the wrong built-in modules (Get-FileHash goes missing); let it use its own.
            psi.EnvironmentVariables.Remove("PSModulePath");
            Encoding oem = Encoding.GetEncoding(CultureInfo.CurrentCulture.TextInfo.OEMCodePage);
            psi.StandardOutputEncoding = oem;
            psi.StandardErrorEncoding = oem;

            log.Clear();
            lineStart = 0;
            crPending = false;
            currentLine.Length = 0;
            currentStep = null;
            failure = null;
            stopping = false;
            resultShown = true;
            try { proc = Process.Start(psi); }
            catch (Exception ex)
            {
                status.Set(StatusKind.Error, "Could not start PowerShell", ex.Message);
                return;
            }
            elapsed.Restart();
            progress.Reset();
            progress.FillColor = Theme.Accent;
            progress.Running = true;
            status.Set(StatusKind.Busy, "Starting the build", "");
            StartTicker();
            UpdateState();

            Process p = proc;
            var readers = new[] { Pump(p.StandardOutput), Pump(p.StandardError) };
            var waiter = new Thread(delegate ()
            {
                foreach (Thread t in readers) t.Join();
                p.WaitForExit();
                int code = p.ExitCode;
                Post(delegate { BuildFinished(code); });
            }) { IsBackground = true };
            waiter.Start();
        }

        void StartTicker()
        {
            if (ticker == null)
            {
                ticker = new System.Windows.Forms.Timer { Interval = 250 };
                ticker.Tick += delegate
                {
                    // Steps without a percentage creep toward their end so the bar keeps moving.
                    if (currentStep != null && progress.Value < currentStep.End)
                        progress.Value += (currentStep.End - progress.Value) * 0.02f;
                    status.Detail = BusyDetail();
                };
            }
            ticker.Start();
        }

        string BusyDetail()
        {
            return (int)(progress.Value * 100) + "%  ·  " + FormatTime(elapsed.Elapsed);
        }

        static string FormatTime(TimeSpan t)
        {
            return (int)t.TotalMinutes + ":" + t.Seconds.ToString("00");
        }

        Thread Pump(StreamReader reader)
        {
            var t = new Thread(delegate ()
            {
                var buffer = new char[4096];
                int n;
                try
                {
                    while ((n = reader.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        string chunk = new string(buffer, 0, n);
                        Post(delegate { AppendOutput(chunk); });
                    }
                }
                catch { }
            }) { IsBackground = true };
            t.Start();
            return t;
        }

        // Runs on the UI thread; dropped if the window is already closing.
        void Post(Action action)
        {
            try { if (!IsDisposed) BeginInvoke(action); }
            catch (InvalidOperationException) { }
        }

        // A folder at the start of a path, written with \ or /, or the Cygwin way
        // (/cygdrive/c/...), as wit echoes paths.
        static Regex PathPattern(string dir, string after)
        {
            string forms = Regex.Escape(dir) + "|" + Regex.Escape(dir.Replace('\\', '/'));
            if (dir.Length > 2 && dir[1] == ':')
                forms += "|" + Regex.Escape("/cygdrive/" + char.ToLowerInvariant(dir[0]) + dir.Substring(2).Replace('\\', '/'));
            return new Regex("(?:" + forms + ")" + after, RegexOptions.IgnoreCase);
        }

        // wit prints the paths it is given in full. Show them the way the script does:
        // relative to the exe's folder, or with the user profile as ~.
        string HidePaths(string text)
        {
            text = rootPrefix.Replace(text, "");
            return homePrefix == null ? text : homePrefix.Replace(text, "~");
        }

        // Appends build output. A lone CR (wit's progress lines) rewrites the current line.
        void AppendOutput(string chunk)
        {
            chunk = HidePaths(chunk);
            var text = new StringBuilder();
            foreach (char c in chunk)
            {
                if (c == '\r') { crPending = true; continue; }
                if (c == '\n')
                {
                    crPending = false;
                    FlushText(text);
                    CommitLine();
                    continue;
                }
                if (crPending)
                {
                    crPending = false;
                    FlushText(text);
                    // A read-only RichTextBox ignores deletes, so unlock it for this one.
                    log.ReadOnly = false;
                    log.Select(lineStart, log.TextLength - lineStart);
                    log.SelectedText = "";
                    log.ReadOnly = true;
                    currentLine.Length = 0;
                }
                text.Append(c);
            }
            FlushText(text);
            TrackPercent(currentLine.ToString());
            log.Select(log.TextLength, 0);
            log.ScrollToCaret();
        }

        void FlushText(StringBuilder text)
        {
            if (text.Length == 0) return;
            AppendLog(text.ToString(), Theme.ConsoleText);
            currentLine.Append(text);
            text.Length = 0;
        }

        void AppendLog(string text, Color color)
        {
            log.Select(log.TextLength, 0);
            log.SelectionColor = color;
            log.SelectedText = text;
        }

        // Colours the finished line and follows the build's steps.
        void CommitLine()
        {
            string line = currentLine.ToString();
            Color color = Color.Empty;
            if (line.StartsWith("==> "))
            {
                color = Theme.ConsoleAccent;
                EnterStep(line.Substring(4));
            }
            else if (line.StartsWith("WARNING")) color = Theme.ConsoleWarn;
            else if (line.StartsWith("BUILD FAILED")) { color = Theme.ConsoleError; failure = line.Substring(line.IndexOf(':') + 1).Trim(); }
            else if (line.StartsWith("Build complete")) color = Theme.ConsoleSuccess;
            if (color != Color.Empty && line.Length > 0)
            {
                log.Select(lineStart, line.Length);
                log.SelectionColor = color;
            }
            AppendLog("\n", Theme.ConsoleText);
            lineStart = log.TextLength;
            currentLine.Length = 0;
        }

        void EnterStep(string text)
        {
            foreach (Step step in Steps)
            {
                if (!text.StartsWith(step.Prefix)) continue;
                currentStep = step;
                if (progress.Value < step.Start) progress.Value = step.Start;
                status.Set(StatusKind.Busy, step.Label, BusyDetail());
                return;
            }
        }

        void TrackPercent(string line)
        {
            if (currentStep == null || !currentStep.Wit) return;
            Match m = Percent.Match(line);
            if (!m.Success) return;
            float pct = Math.Min(100, int.Parse(m.Groups[1].Value)) / 100f;
            float value = currentStep.Start + (currentStep.End - currentStep.Start) * pct;
            if (value > progress.Value) progress.Value = value;
        }

        void BuildFinished(int exitCode)
        {
            bool stopped = stopping;
            proc = null;
            stopping = false;
            elapsed.Stop();
            if (ticker != null) ticker.Stop();
            progress.Running = false;
            string time = FormatTime(elapsed.Elapsed);
            tips.SetToolTip(status, null);
            if (stopped)
            {
                RestorePackNames();
                AppendLog("\nBuild stopped. The next build clears the temporary files in the work folder.\n", Theme.ConsoleWarn);
                status.Set(StatusKind.Warn, "Build stopped", "after " + time);
                progress.FillColor = Theme.Warn;
            }
            else if (exitCode == 0)
            {
                status.Set(StatusKind.Success, "Build complete", "in " + time);
                progress.Value = 1f;
                progress.FillColor = Theme.Success;
                System.Media.SystemSounds.Asterisk.Play();
            }
            else
            {
                status.Set(StatusKind.Error, "Build failed", failure ?? "See the end of the build log.");
                if (failure != null) tips.SetToolTip(status, failure);
                progress.FillColor = Theme.Error;
            }
            log.Select(log.TextLength, 0);
            log.ScrollToCaret();

            try
            {
                Directory.CreateDirectory(paths.Output);
                File.WriteAllText(Path.Combine(paths.Output, "build-log.txt"), log.Text.Replace("\n", "\r\n"), Encoding.UTF8);
            }
            catch { }
            UpdateState();
        }

        void StopBuild(bool closing)
        {
            if (!IsBuilding || stopping) return;
            if (!closing && MessageBox.Show(this, "Stop the build?", "RetroPadU", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) return;
            stopping = true;
            status.Set(StatusKind.Busy, "Stopping", "");
            UpdateState();
            // PowerShell runs wit and cmd.exe as children, so end the whole tree.
            try
            {
                var kill = Process.Start(new ProcessStartInfo("taskkill.exe", "/T /F /PID " + proc.Id) { CreateNoWindow = true, UseShellExecute = false });
                kill.WaitForExit(10000);
            }
            catch { }
        }

        // copy-files.bat renames these while it runs; the script puts them back, but
        // not when the build is stopped in the middle.
        void RestorePackNames()
        {
            if (pack.Value == null) return;
            string lang = Path.Combine(pack.Value, "Language");
            string[,] pairs = { { "SPAEU", "SPA(EU)" }, { "SPANTSC", "SPA(NTSC)" } };
            for (int i = 0; i < pairs.GetLength(0); ++i)
            {
                string from = Path.Combine(lang, pairs[i, 0]), to = Path.Combine(lang, pairs[i, 1]);
                try { if (Directory.Exists(from) && !Directory.Exists(to)) Directory.Move(from, to); } catch { }
            }
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            if (IsBuilding)
            {
                if (MessageBox.Show(this, "A build is running. Stop it and close RetroPadU?", "RetroPadU",
                        MessageBoxButtons.YesNo, MessageBoxIcon.Warning) != DialogResult.Yes)
                {
                    e.Cancel = true;
                    return;
                }
                Process p = proc;
                StopBuild(true);
                try { p.WaitForExit(5000); } catch { }
                RestorePackNames();
            }
            else SaveSettings();
            base.OnFormClosing(e);
        }

        // ---------------------------------------------------------------- misc

        void OpenOutput()
        {
            Directory.CreateDirectory(paths.Output);
            Process.Start("explorer.exe", QuoteArg(paths.Output));
        }

        void CopyLog()
        {
            if (log.TextLength == 0) return;
            try { Clipboard.SetText(log.Text.Replace("\n", "\r\n")); } catch { }
        }

        static void OpenUrl(string url)
        {
            try { Process.Start(url); } catch { }
        }

        string FindWit()
        {
            if (paths.Wit != null) return paths.Wit;
            string path = Environment.GetEnvironmentVariable("PATH") ?? "";
            foreach (string dir in path.Split(';'))
            {
                try
                {
                    string candidate = Path.Combine(dir.Trim().Trim('"'), "wit.exe");
                    if (dir.Trim().Length > 0 && File.Exists(candidate)) return candidate;
                }
                catch { }
            }
            foreach (string pf in new[] { Environment.GetEnvironmentVariable("ProgramFiles"), Environment.GetEnvironmentVariable("ProgramFiles(x86)") })
            {
                if (string.IsNullOrEmpty(pf)) continue;
                string candidate = Path.Combine(pf, @"Wiimm\WIT\wit.exe");
                if (File.Exists(candidate)) return candidate;
            }
            return null;
        }

        // Shows a path the way the build log does: relative to the RetroPadU folder,
        // or with the user profile as ~.
        string ShortPath(string path)
        {
            string prefix = root + "\\";
            if (path.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) return path.Substring(prefix.Length);
            string home = Environment.GetEnvironmentVariable("USERPROFILE");
            if (!string.IsNullOrEmpty(home))
            {
                home = home.TrimEnd('\\');
                if (path.StartsWith(home + "\\", StringComparison.OrdinalIgnoreCase)) return "~" + path.Substring(home.Length);
            }
            return path;
        }

        // Quotes one argument for the Windows command line (CommandLineToArgvW rules).
        static string QuoteArg(string arg)
        {
            if (arg.Length > 0 && arg.IndexOfAny(new[] { ' ', '\t', '"' }) < 0) return arg;
            var sb = new StringBuilder("\"");
            int slashes = 0;
            foreach (char c in arg)
            {
                if (c == '\\') { ++slashes; continue; }
                if (c == '"') { sb.Append('\\', slashes * 2 + 1); sb.Append('"'); }
                else { sb.Append('\\', slashes); sb.Append(c); }
                slashes = 0;
            }
            sb.Append('\\', slashes * 2);
            sb.Append('"');
            return sb.ToString();
        }
    }

    static class NativeMethods
    {
        [DllImport("dwmapi.dll")]
        static extern int DwmSetWindowAttribute(IntPtr hwnd, int attribute, ref int value, int size);

        [DllImport("user32.dll")]
        public static extern bool HideCaret(IntPtr hwnd);

        [DllImport("uxtheme.dll", CharSet = CharSet.Unicode)]
        public static extern int SetWindowTheme(IntPtr hwnd, string app, string idList);

        // Fails harmlessly on Windows versions without the attribute.
        public static void SetDwm(IntPtr hwnd, int attribute, int value)
        {
            try { DwmSetWindowAttribute(hwnd, attribute, ref value, 4); } catch { }
        }
    }

    // The Explorer-style folder picker (IFileOpenDialog with FOS_PICKFOLDERS). .NET
    // Framework's FolderBrowserDialog is the old tree view, which is hard to use.
    static class FolderPicker
    {
        public static string Pick(IWin32Window owner, string title, string start)
        {
            try
            {
                var dialog = (IFileOpenDialog)new FileOpenDialogCom();
                try
                {
                    uint options;
                    dialog.GetOptions(out options);
                    dialog.SetOptions(options | FOS_PICKFOLDERS | FOS_FORCEFILESYSTEM);
                    dialog.SetTitle(title);
                    if (start != null && Directory.Exists(start))
                    {
                        IShellItem folder;
                        if (SHCreateItemFromParsingName(start, IntPtr.Zero, typeof(IShellItem).GUID, out folder) == 0) dialog.SetFolder(folder);
                    }
                    if (dialog.Show(owner.Handle) != 0) return null;
                    IShellItem result;
                    dialog.GetResult(out result);
                    string path;
                    result.GetDisplayName(SIGDN_FILESYSPATH, out path);
                    return path;
                }
                finally { Marshal.ReleaseComObject(dialog); }
            }
            catch (COMException) { }
            catch (InvalidCastException) { }

            using (var fallback = new FolderBrowserDialog { Description = title, ShowNewFolderButton = false })
            {
                if (start != null && Directory.Exists(start)) fallback.SelectedPath = start;
                return fallback.ShowDialog(owner) == DialogResult.OK ? fallback.SelectedPath : null;
            }
        }

        const uint FOS_PICKFOLDERS = 0x20, FOS_FORCEFILESYSTEM = 0x40, SIGDN_FILESYSPATH = 0x80058000;

        [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
        static extern int SHCreateItemFromParsingName(string path, IntPtr bindCtx, [MarshalAs(UnmanagedType.LPStruct)] Guid riid, out IShellItem item);

        [ComImport, Guid("DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7")]
        class FileOpenDialogCom { }

        // Only the methods up to GetResult are declared; the vtable order must match.
        [ComImport, Guid("d57c7288-d4ad-4768-be02-9d969532d960"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        interface IFileOpenDialog
        {
            [PreserveSig] int Show(IntPtr parent);
            void SetFileTypes(uint count, IntPtr specs);
            void SetFileTypeIndex(uint index);
            void GetFileTypeIndex(out uint index);
            void Advise(IntPtr events, out uint cookie);
            void Unadvise(uint cookie);
            void SetOptions(uint options);
            void GetOptions(out uint options);
            void SetDefaultFolder(IShellItem item);
            void SetFolder(IShellItem item);
            void GetFolder(out IShellItem item);
            void GetCurrentSelection(out IShellItem item);
            void SetFileName([MarshalAs(UnmanagedType.LPWStr)] string name);
            void GetFileName([MarshalAs(UnmanagedType.LPWStr)] out string name);
            void SetTitle([MarshalAs(UnmanagedType.LPWStr)] string title);
            void SetOkButtonLabel([MarshalAs(UnmanagedType.LPWStr)] string text);
            void SetFileNameLabel([MarshalAs(UnmanagedType.LPWStr)] string label);
            void GetResult(out IShellItem item);
        }

        [ComImport, Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        interface IShellItem
        {
            void BindToHandler(IntPtr bindCtx, [In] ref Guid bhid, [In] ref Guid riid, out IntPtr ppv);
            void GetParent(out IShellItem parent);
            void GetDisplayName(uint sigdn, [MarshalAs(UnmanagedType.LPWStr)] out string name);
        }
    }
}
