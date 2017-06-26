using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Microsoft.VisualBasic.PowerPacks;
using SbsSW.SwiPlCs;
using System.Diagnostics;
using System.Windows;



namespace WindowsFormsApp3
{
    public partial class Form1 : Form
    {
        String currentLabel = "a";
        Point[] LocationArray = new Point[2];
        List<string> edgesArray;
        List<string> connectionArray;
        ShapeContainer canvas;
        Label toClear;
        List<Label> labelList = new List<Label> { };
        List<string> labels = new List<string> { };
        List<int> values = new List<int> { };


        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            edgesArray = new List<string> { };
            connectionArray = new List<string> { };
            canvas = new ShapeContainer();
            canvas.Parent = this;

        }

        private void Form1_Click(object sender, EventArgs e)
        {
            Label label = new Label { Location = this.PointToClient(Cursor.Position), AutoSize = true, Text = currentLabel, BorderStyle = BorderStyle.Fixed3D, Margin = new Padding(10) };
            label.Click += new EventHandler(LabelClick);
            labelList.Add(label);
            Controls.Add(label);
            int convertedLabel = Convert.ToChar(currentLabel) + 1;
            currentLabel = Convert.ToString(Convert.ToChar(convertedLabel));
            edgesArray.Add(label.Text.ToString());
        }

        private void LabelClick(object sender, EventArgs e)
        {
            Label tmpLabel = sender as Label;
            if (tmpLabel != null)
            {
                if (LocationArray[0] != Point.Empty)
                {
                    LocationArray[1] = this.PointToClient(Cursor.Position);

                    LineShape line = new LineShape(LocationArray[0].X, LocationArray[0].Y, LocationArray[1].X, LocationArray[1].Y);
                    line.Parent = this.canvas;
                    line.BorderColor = Color.Black;
                    line.BorderStyle = System.Drawing.Drawing2D.DashStyle.Solid;
                    Rectangle approx = (new Rectangle(new Point(((line.X1 + line.X2) / 2) - 10, ((line.Y1 + line.Y2) / 2) - 10), new System.Drawing.Size(20, 20)));
                    Point loc = new Point((line.X1 + line.X2) / 2, (line.Y1 + line.Y2) / 2);
                    Label collision = labelList.Find(x => approx.Contains(x.Location));
                    if (collision != null)
                    {
                        collision.Location = new Point(collision.Location.X + 20, collision.Location.Y + 20);
                        loc = new Point((3 * line.X1 + line.X2) / 4, (3 * line.Y1 + line.Y2) / 4);

                    }
                    Label lineLabel = new Label { Location = loc, AutoSize = true, Text = currentLabel, Margin = new Padding(10) };
                    Controls.Add(lineLabel);
                    lineLabel.Location = new Point((lineLabel.Location.X - lineLabel.Width / 2), (lineLabel.Location.Y - lineLabel.Height / 2));
                    int convertedLabel = Convert.ToChar(currentLabel) + 1;
                    labelList.Add(lineLabel);
                    currentLabel = Convert.ToString(Convert.ToChar(convertedLabel));
                    connectionArray.Add(lineLabel.Text.ToString());
                    connectionArray.Add(tmpLabel.Text.ToString());
                    LocationArray[0] = LocationArray[1] = Point.Empty;
                    toClear.BackColor = Color.Transparent;
                }
                else
                {
                    LocationArray[0] = this.PointToClient(Cursor.Position);
                    connectionArray.Add(tmpLabel.Text.ToString());
                    tmpLabel.BackColor = Color.Red;
                    toClear = tmpLabel;
                }


            }
        }

        private void button1_Click(object sender, EventArgs e)
        {

            string LocalPath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().CodeBase);
            LocalPath = '\u0022' + LocalPath.Substring(6, LocalPath.Length - 6);

            string edges = "";
            string vertexes = "[";

            foreach (string edge in edgesArray.ToArray())
            {
                vertexes += edge + ",";
            }
            vertexes = vertexes.Substring(0, vertexes.Length - 1) + "]";

            for (int i = 0; i < connectionArray.ToArray().Length; i++)
            {
                switch (i % 3)
                {
                    case 0:
                        edges += "edge(" + connectionArray[i] + ",";
                        break;
                    case 1:
                        edges += connectionArray[i + 1] + ",";
                        break;
                    case 2:
                        edges += connectionArray[i - 1] + "),";
                        break;
                }

            }
            edges = edges.Substring(0, edges.Length - 1);




            Process proc = new System.Diagnostics.Process();
            proc.StartInfo.FileName = @"cmd.exe";
            proc.StartInfo.Arguments = "/K cd C:\\Program Files (x86)\\swipl\\bin & swipl.exe -q -f " + LocalPath + "\\vamtl.pl" + '\u0022';
            proc.StartInfo.UseShellExecute = false;
            proc.StartInfo.RedirectStandardOutput = true;
            proc.StartInfo.RedirectStandardInput = true;
            proc.StartInfo.CreateNoWindow = true;
            proc.Start();
            proc.StandardInput.WriteLine("set_prolog_flag(answer_write_options,[quoted(true),portray(true),spacing(next_argument)]).");
            proc.StandardInput.WriteLine("startVAMTL([" + edges + "," + vertexes + ",end_of_file],R)");
            proc.StandardInput.WriteLine(".");
            proc.StandardInput.Close();
            proc.WaitForExit();



            String rzecz = proc.StandardOutput.ReadLine();
            rzecz = proc.StandardOutput.ReadLine();
            rzecz = proc.StandardOutput.ReadLine();
            proc.StandardOutput.Close();
            rzecz = rzecz.Substring(6, rzecz.Length - 9);


            foreach (string qwe in rzecz.Split(new string[] { "], [" }, StringSplitOptions.None)[0].Split(new string[] { ", " }, StringSplitOptions.None))
            {
                labels.Add(qwe);
            }

            foreach (string qwe in rzecz.Split(new string[] { "], [" }, StringSplitOptions.None)[1].Split(new string[] { ", " }, StringSplitOptions.None))
            {
                values.Add(Convert.ToInt32(qwe));
            }
            foreach (string asd in labels)
            {
                int index = labels.IndexOf(asd);
                labelList.Find(x => x.Text.Contains(asd)).Text = asd + "=" + values[index].ToString();
            }




        }

        private void button2_Click(object sender, EventArgs e)
        {
            currentLabel = "a";
            LocationArray = new Point[2];
            edgesArray = new List<string> { };
            connectionArray = new List<string> { };
            canvas.Dispose();
            foreach (Label labelToDispose in labelList)
            {
                labelToDispose.Dispose();
            }
            labelList = new List<Label> { };
            this.Refresh();
            canvas = new ShapeContainer();
            canvas.Parent = this;
            toClear = null;
            labelList = new List<Label> { };
            labels = new List<string> { };
            values = new List<int> { };

        }
    }
}
