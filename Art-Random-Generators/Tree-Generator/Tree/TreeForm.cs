using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Tree
{
    public partial class TreeForm : Form
    {
        public class Branch
        {
            public Branch() { }
            public float x1, y1, x2, y2;
            public float angle;
            public int level;
        }
        const int canvasSize = 800;
        const int canvasSizeY = 900;

        int initLev = 10;

        float angleDelta = 0.5869F;
        float ratio = 0.69F;
        float angleVariation = 0.1571F;
        float distVariation = 0.1F;
        float initHeight = 200;
        float offset = 0;
        bool doubleFirst = false;
        bool weird2First = false;
        bool weird1First = false;
        float probOfThird = 0.065F;
        int time=0;

        List<Branch> allBranches = new List<Branch>();

        void growBranch(ref Branch newB, float dist, ref Random rand, bool randomise)
        {
            float shiftx;
            float shifty;
            if (randomise)
            {
                newB.angle += (float)rand.NextDouble() * 2 * angleVariation - angleVariation;
                dist *= (float)rand.NextDouble() * 2 * distVariation + 1 - distVariation;
            }
            shiftx = -((float)Math.Sin(newB.angle)) * dist;
            shifty = -((float)Math.Cos(newB.angle)) * dist;
            newB.x2 = newB.x1 + shiftx;
            newB.y2 = newB.y1 + shifty;
        }

        void generate()
        {
            allBranches.Clear();
            Random rand = new Random();
            Branch currB;
            Branch newB = new Branch();
            Queue<Branch> q = new Queue<Branch>();
            float dist;

            dist = initHeight;
            newB.x1 = canvasSize / 2;
            newB.y1 = canvasSizeY;
            newB.level = initLev;
            newB.angle = 0;
            growBranch(ref newB, dist, ref rand, false);
            q.Enqueue(newB);
            while (q.Count > 0)
            {
                currB = (Branch)q.Dequeue();
                allBranches.Add(currB);
                if (currB.level > 1)
                {
                    dist = (float)(Math.Sqrt((currB.x1 - currB.x2) * (currB.x1 - currB.x2) + (currB.y1 - currB.y2) * (currB.y1 - currB.y2))) * ratio;

                    if (currB.level == initLev && weird1First == true)
                    {
                        int dir;
                        if (rand.Next() % 2 == 0) dir = 1;
                        else dir = -1;
                        dist /= ratio;
                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle - dir*0.35F;
                        growBranch(ref newB, dist, ref rand, true);
                        newB.angle = currB.angle;
                        q.Enqueue(newB);
                    }
                    else if (currB.level == initLev && weird2First == true)
                    {
                        int dir;
                        if (rand.Next() % 2 == 0) dir = 1;
                        else dir = -1;
                        dist /= ratio;
                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle - dir*0.2F;
                        growBranch(ref newB, dist, ref rand, true);
                        newB.angle = currB.angle;
                        q.Enqueue(newB);

                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle + dir*1F;
                        growBranch(ref newB, dist, ref rand, true);
                        newB.angle = currB.angle;
                        q.Enqueue(newB);
                    }
                    else if (currB.level == initLev && doubleFirst == true)
                    {
                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle + 0.5F * angleDelta;
                        growBranch(ref newB, dist, ref rand, true);
                        q.Enqueue(newB);

                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle - 0.5F * angleDelta;
                        growBranch(ref newB, dist, ref rand, true);
                        q.Enqueue(newB);

                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle - 1.5F * angleDelta;
                        growBranch(ref newB, dist, ref rand, true);
                        q.Enqueue(newB);

                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle + 1.5F * angleDelta;
                        growBranch(ref newB, dist, ref rand, true);
                        q.Enqueue(newB);
                    }
                    else
                    {
                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle + angleDelta;
                        growBranch(ref newB, dist, ref rand, true);
                        q.Enqueue(newB);

                        newB = new Branch();
                        newB.x1 = currB.x2;
                        newB.y1 = currB.y2;
                        newB.level = currB.level - 1;
                        newB.angle = currB.angle - angleDelta;
                        growBranch(ref newB, dist, ref rand, true);
                        q.Enqueue(newB);

                        if (rand.NextDouble() <= probOfThird)
                        {
                            newB = new Branch();
                            newB.x1 = currB.x2;
                            newB.y1 = currB.y2;
                            newB.level = currB.level - 1;
                            newB.angle = currB.angle;
                            growBranch(ref newB, dist, ref rand, true);
                            q.Enqueue(newB);
                        }
                    }
                }
            }
        }

        const int windowSizeX = 817;
        const int windowSizeY = 940;


        Color tree = Color.SaddleBrown;
        Color flower = Color.Pink;
        Color leaf = Color.Green;
        Color cherry0 = Color.LimeGreen;
        Color cherry1 = Color.FromArgb(217, 231, 120);
        Color cherry2 = Color.FromArgb(242, 210, 119);
        Color cherry3 = Color.FromArgb(250, 183, 147);
        Color cherry4 = Color.FromArgb(228, 126, 101);
        Color cherry5 = Color.FromArgb(208, 49, 36);
        Color cherry6 = Color.FromArgb(177, 0, 28);
        Color cherry7 = Color.FromArgb(105, 0, 0);
        Color autumnLeaf1 = Color.Gold;
        Color autumnLeaf2 = Color.Orange;
        Color autumnLeaf3 = Color.OrangeRed;
        Color autumnLeaf4 = Color.Firebrick;


        protected override void OnPaint(PaintEventArgs e)
        {
            this.MinimumSize = new Size(windowSizeX, windowSizeY);
            this.MaximumSize = new Size(windowSizeX, windowSizeY);
            Random rand = new Random();
            Graphics g = e.Graphics;;
            Pen currPen;
            foreach (Branch currB in allBranches)
            {
                if (currB.level > 4) currPen = new Pen(tree, 2);
                else
                {
                    currPen = new Pen(leaf, 3);
                    if (time == 0)
                    {
                        if (currB.level <= 2 || (currB.level == 3 && rand.Next() % 2 == 0)) continue;
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 1)
                    {
                        if (currB.level == 1 || (currB.level == 2 && rand.Next() % 2 == 0)) continue;
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 2)
                    {
                        if (currB.level == 1 && rand.Next() % 2 == 0) continue;
                        else if (currB.level == 1 && rand.Next() % 3 == 0) currPen = new Pen(flower, 5);
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 3)
                    {
                        if (currB.level == 1 && rand.Next() % 3 == 0) currPen = new Pen(flower, 5);
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 4)
                    {
                        if (currB.level == 1 && rand.Next() % 4 == 0) currPen = new Pen(flower, 5);
                        else if (currB.level == 1 || (currB.level == 2 && rand.Next() % 2 == 0)) currPen = new Pen(leaf, 3);
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 5)
                    {
                        if (currB.level == 1 && rand.Next() % 6 == 0) currPen = new Pen(flower, 5);
                        else if (currB.level <= 2 || (currB.level == 3 && rand.Next() % 2 == 0)) currPen = new Pen(leaf, 3);
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 6)
                    {
                        if (currB.level == 1 && rand.Next() % 10 == 0) currPen = new Pen(flower, 5);
                        else if (currB.level <= 3 || (currB.level == 4 && rand.Next() % 2 == 0)) currPen = new Pen(leaf, 3);
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 7)
                    {
                        currPen = new Pen(leaf, 3);
                    }
                    else if (time == 8)
                    {
                        if (currB.level == 1 && rand.Next() % 9 == 0) currPen = new Pen(cherry0, 5);
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 9)
                    {
                        if (currB.level == 1 && rand.Next() % 5 == 0)
                        {
                            if (rand.Next() % 2 == 0) currPen = new Pen(cherry1, 5);
                            else currPen = new Pen(cherry0, 5);
                        }
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 10)
                    {
                        if (currB.level == 1 && rand.Next() % 3 == 0)
                        {
                            if (rand.Next() % 2 == 0) currPen = new Pen(cherry2, 5);
                            else currPen = new Pen(cherry1, 5);
                        }
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 11)
                    {
                        if (currB.level == 1 && rand.Next() % 3 == 0)
                        {
                            if (rand.Next() % 5 <= 1) currPen = new Pen(cherry3, 5);
                            else if (rand.Next() % 3 <= 1) currPen = new Pen(cherry2, 5);
                            else currPen = new Pen(cherry1, 5);
                        }
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 12)
                    {
                        if (currB.level == 1 && rand.Next() % 3 == 0)
                        {
                            if (rand.Next() % 6 == 0) currPen = new Pen(cherry5, 5);
                            else if (rand.Next() % 2 == 0) currPen = new Pen(cherry4, 5);
                            else if (rand.Next() % 3 <= 1) currPen = new Pen(cherry3, 5);
                            else currPen = new Pen(cherry2, 5);
                        }
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 13)
                    {
                        if (currB.level == 1 && rand.Next() % 3 == 0)
                        {
                            if (rand.Next() % 5 <= 1) currPen = new Pen(cherry6, 5);
                            else if (rand.Next() % 3 <= 1) currPen = new Pen(cherry5, 5);
                            else if (rand.Next() % 3 <= 1) currPen = new Pen(cherry4, 5);
                            else currPen = new Pen(cherry3, 5);
                        }
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 14)
                    {
                        if (currB.level == 1 && rand.Next() % 3 == 0)
                        {
                            if (rand.Next() % 3 == 0) currPen = new Pen(cherry7, 5);
                            else if (rand.Next() % 3 == 0) currPen = new Pen(cherry6, 5);
                            else currPen = new Pen(cherry5, 5);
                        }
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 15)
                    {
                        if (currB.level == 1 && rand.Next() % 5 == 0)
                        {
                            if (rand.Next() % 2 == 0) currPen = new Pen(cherry7, 5);
                            else currPen = new Pen(cherry6, 5);
                        }
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 16)
                    {
                        if (currB.level == 1 && rand.Next() % 8 == 0) if (rand.Next() % 2 == 0) currPen = new Pen(cherry7, 5);
                        else currPen = new Pen(leaf, 3);
                    }
                    else if (time == 17)
                    {
                        currPen = new Pen(leaf, 3);
                    }
                    else if (time == 18)
                    {
                        if (rand.Next() % 5 <= 3) currPen = new Pen(leaf, 3);
                        else currPen = new Pen(autumnLeaf1, 3);
                    }
                    else if (time == 19)
                    {
                        if (rand.Next() % 5 <= 2) currPen = new Pen(leaf, 3);
                        else if (rand.Next() % 3 <= 1) currPen = new Pen(autumnLeaf1, 3);
                        else currPen = new Pen(autumnLeaf2, 3);
                    }
                    else if (time == 20)
                    {
                        if (rand.Next() % 5 <= 1) currPen = new Pen(leaf, 3);
                        else if (rand.Next() % 2 == 0) currPen = new Pen(autumnLeaf1, 3);
                        else currPen = new Pen(autumnLeaf2, 3);
                    }
                    else if (time == 21)
                    {
                        if (rand.Next() % 5 == 0) currPen = new Pen(leaf, 3);
                        else if (rand.Next() % 3 == 0) currPen = new Pen(autumnLeaf1, 3);
                        else if (rand.Next() % 3 <= 1) currPen = new Pen(autumnLeaf2, 3);
                        else currPen = new Pen(autumnLeaf3, 3);
                    }
                    else if (time == 22)
                    {
                        if (rand.Next() % 5 <= 1) currPen = new Pen(autumnLeaf1, 3);
                        else if (rand.Next() % 2 == 0) currPen = new Pen(autumnLeaf2, 3);
                        else currPen = new Pen(autumnLeaf3, 3);
                    }
                    else if (time == 23)
                    {
                        if (currB.level == 1 && rand.Next() % 2 == 0) continue;
                        else if (rand.Next() % 4 == 0) currPen = new Pen(autumnLeaf1, 3);
                        else if (rand.Next() % 3 == 0) currPen = new Pen(autumnLeaf2, 3);
                        else if (rand.Next() % 2 == 0) currPen = new Pen(autumnLeaf3, 3);
                        else currPen = new Pen(autumnLeaf4, 3);
                    }
                    else if (time == 24)
                    {
                        if (currB.level <= 1 || (currB.level == 2 && rand.Next() % 3 == 0)) continue;
                        else if (currB.level <= 3 || (currB.level == 4 && rand.Next() % 3 <= 2))
                        {
                            if (rand.Next() % 4 == 0) currPen = new Pen(autumnLeaf1, 3);
                            else if (rand.Next() % 3 == 0) currPen = new Pen(autumnLeaf2, 3);
                            else if (rand.Next() % 2 == 0) currPen = new Pen(autumnLeaf3, 3);
                            else currPen = new Pen(autumnLeaf4, 3);
                        }
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 25)
                    {
                        if (currB.level <= 1 || (currB.level == 2 && rand.Next() % 2 == 0)) continue;
                        else if (currB.level == 2 || (currB.level == 3 && rand.Next() % 2 == 0))
                        {
                            if (rand.Next() % 4 == 0) currPen = new Pen(autumnLeaf1, 3);
                            else if (rand.Next() % 3 == 0) currPen = new Pen(autumnLeaf2, 3);
                            else if (rand.Next() % 2 == 0) currPen = new Pen(autumnLeaf3, 3);
                            else currPen = new Pen(autumnLeaf4, 3);
                        }
                        else currPen = new Pen(tree, 2);
                    }
                    else if (time == 26)
                    {
                        if (currB.level <= 2 || (currB.level == 3 && rand.Next() % 2 == 0)) continue;
                        else currPen = new Pen(tree, 2);
                    }
                }
                g.DrawLine(currPen, currB.x1, currB.y1 - offset, currB.x2, currB.y2 - offset);
            }
        }

        private void Form1_Load(object sender, EventArgs e) { }
        public TreeForm()
        {
            InitializeComponent();
            generate();
            this.Refresh();
        }
        private void angleDeltaSlider_Scroll(object sender, EventArgs e)
        {
            angleDelta = angleDeltaSlider.Value / 200.0F * (float)Math.PI;
            generate();
            this.Refresh();
        }
        private void ratioSlider_Scroll(object sender, EventArgs e)
        {
            ratio = ratioSlider.Value / 200.0F;
            if (distVariation > 1 / ratio - 1)
            {
                distanceVariationSlider.Value = (int)(200 / ratio - 200);
                distVariation = distanceVariationSlider.Value / 200.0F;
            }
            generate();
            this.Refresh();
        }
        private void angleVariationSlider_Scroll(object sender, EventArgs e)
        {
            angleVariation = angleVariationSlider.Value / 200.0F * (float)Math.PI / 2;
            generate();
            this.Refresh();
        }
        private void distanceVariationSlider_Scroll(object sender, EventArgs e)
        {
            distVariation = distanceVariationSlider.Value / 200.0F;
            if (distVariation > 1 / ratio - 1)
            {
                distanceVariationSlider.Value = (int)(200 / ratio - 200);
                distVariation = distanceVariationSlider.Value / 200.0F;
            }
            generate();
            this.Refresh();
        }
        private void thirdProbabilitySlider_Scroll(object sender, EventArgs e)
        {
            probOfThird = thirdProbabilitySlider.Value / 200.0F;
            generate();
            this.Refresh();
        }
        private void heightSlider_Scroll(object sender, EventArgs e)
        {
            initHeight = heightSlider.Value / 200.0F * canvasSize / 2;
            generate();
            this.Refresh();
        }
        private void timeSlider_Scroll(object sender, EventArgs e)
        {
            time = timeSlider.Value;
            if (time == 26)
            {
                time = 0;
                timeSlider.Value = 0;
            }
            this.Refresh();
        }
        private void offsetSlider_Scroll(object sender, EventArgs e)
        {
            offset = offsetSlider.Value / 200.0F * 2 * canvasSize - canvasSize;
            this.Refresh();
        }
        private void generateBtn_Click(object sender, EventArgs e)
        {
            generate();
            this.Refresh();
        }

        private void modeBtn_Click(object sender, EventArgs e)
        {
            if (doubleFirst == false && weird2First == false && weird1First == false) doubleFirst = true;
            else if (doubleFirst == true)
            {
                doubleFirst = false;
                weird2First = true;
            }
            else if (weird2First == true)
            {
                weird2First = false;
                weird1First = true;
            }
            else weird1First = false;
            generate();
            this.Refresh();
        }
    }
}
