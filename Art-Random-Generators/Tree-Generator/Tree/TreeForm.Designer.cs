namespace Tree
{
    partial class TreeForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.angleDeltaSlider = new System.Windows.Forms.TrackBar();
            this.ratioSlider = new System.Windows.Forms.TrackBar();
            this.offsetSlider = new System.Windows.Forms.TrackBar();
            this.heightSlider = new System.Windows.Forms.TrackBar();
            this.timeSlider = new System.Windows.Forms.TrackBar();
            this.distanceVariationSlider = new System.Windows.Forms.TrackBar();
            this.angleVariationSlider = new System.Windows.Forms.TrackBar();
            this.thirdProbabilitySlider = new System.Windows.Forms.TrackBar();
            this.modeBtn = new System.Windows.Forms.Button();
            this.generateBtn = new System.Windows.Forms.Button();
            this.panel1 = new System.Windows.Forms.Panel();
            ((System.ComponentModel.ISupportInitialize)(this.angleDeltaSlider)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.ratioSlider)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.offsetSlider)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.heightSlider)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.timeSlider)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.distanceVariationSlider)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.angleVariationSlider)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.thirdProbabilitySlider)).BeginInit();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // angleDeltaSlider
            // 
            this.angleDeltaSlider.Location = new System.Drawing.Point(0, 0);
            this.angleDeltaSlider.Maximum = 200;
            this.angleDeltaSlider.Name = "angleDeltaSlider";
            this.angleDeltaSlider.Size = new System.Drawing.Size(460, 56);
            this.angleDeltaSlider.TabIndex = 0;
            this.angleDeltaSlider.Value = 38;
            this.angleDeltaSlider.Scroll += new System.EventHandler(this.angleDeltaSlider_Scroll);
            // 
            // ratioSlider
            // 
            this.ratioSlider.Location = new System.Drawing.Point(609, 0);
            this.ratioSlider.Maximum = 200;
            this.ratioSlider.Name = "ratioSlider";
            this.ratioSlider.Size = new System.Drawing.Size(460, 56);
            this.ratioSlider.TabIndex = 1;
            this.ratioSlider.Value = 135;
            this.ratioSlider.Scroll += new System.EventHandler(this.ratioSlider_Scroll);
            // 
            // offsetSlider
            // 
            this.offsetSlider.Location = new System.Drawing.Point(535, 166);
            this.offsetSlider.Maximum = 200;
            this.offsetSlider.Name = "offsetSlider";
            this.offsetSlider.Size = new System.Drawing.Size(534, 56);
            this.offsetSlider.TabIndex = 3;
            this.offsetSlider.Value = 100;
            this.offsetSlider.Scroll += new System.EventHandler(this.offsetSlider_Scroll);
            // 
            // heightSlider
            // 
            this.heightSlider.Location = new System.Drawing.Point(609, 111);
            this.heightSlider.Maximum = 200;
            this.heightSlider.Name = "heightSlider";
            this.heightSlider.Size = new System.Drawing.Size(460, 56);
            this.heightSlider.TabIndex = 2;
            this.heightSlider.Value = 100;
            this.heightSlider.Scroll += new System.EventHandler(this.heightSlider_Scroll);
            // 
            // timeSlider
            // 
            this.timeSlider.Location = new System.Drawing.Point(0, 166);
            this.timeSlider.Maximum = 26;
            this.timeSlider.Name = "timeSlider";
            this.timeSlider.Size = new System.Drawing.Size(535, 56);
            this.timeSlider.TabIndex = 4;
            this.timeSlider.Scroll += new System.EventHandler(this.timeSlider_Scroll);
            // 
            // distanceVariationSlider
            // 
            this.distanceVariationSlider.Location = new System.Drawing.Point(609, 55);
            this.distanceVariationSlider.Maximum = 200;
            this.distanceVariationSlider.Name = "distanceVariationSlider";
            this.distanceVariationSlider.Size = new System.Drawing.Size(460, 56);
            this.distanceVariationSlider.TabIndex = 5;
            this.distanceVariationSlider.Value = 20;
            this.distanceVariationSlider.Scroll += new System.EventHandler(this.distanceVariationSlider_Scroll);
            // 
            // angleVariationSlider
            // 
            this.angleVariationSlider.Location = new System.Drawing.Point(0, 55);
            this.angleVariationSlider.Maximum = 200;
            this.angleVariationSlider.Name = "angleVariationSlider";
            this.angleVariationSlider.Size = new System.Drawing.Size(460, 56);
            this.angleVariationSlider.TabIndex = 6;
            this.angleVariationSlider.Value = 20;
            this.angleVariationSlider.Scroll += new System.EventHandler(this.angleVariationSlider_Scroll);
            // 
            // thirdProbabilitySlider
            // 
            this.thirdProbabilitySlider.Location = new System.Drawing.Point(0, 111);
            this.thirdProbabilitySlider.Maximum = 200;
            this.thirdProbabilitySlider.Name = "thirdProbabilitySlider";
            this.thirdProbabilitySlider.Size = new System.Drawing.Size(460, 56);
            this.thirdProbabilitySlider.TabIndex = 7;
            this.thirdProbabilitySlider.Value = 13;
            this.thirdProbabilitySlider.Scroll += new System.EventHandler(this.thirdProbabilitySlider_Scroll);
            // 
            // modeBtn
            // 
            this.modeBtn.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.modeBtn.Location = new System.Drawing.Point(16, 12);
            this.modeBtn.Name = "modeBtn";
            this.modeBtn.Size = new System.Drawing.Size(137, 68);
            this.modeBtn.TabIndex = 8;
            this.modeBtn.Text = "Switch mode";
            this.modeBtn.UseVisualStyleBackColor = true;
            this.modeBtn.Click += new System.EventHandler(this.modeBtn_Click);
            // 
            // generateBtn
            // 
            this.generateBtn.Font = new System.Drawing.Font("Microsoft Sans Serif", 11F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.generateBtn.Location = new System.Drawing.Point(16, 92);
            this.generateBtn.Name = "generateBtn";
            this.generateBtn.Size = new System.Drawing.Size(137, 68);
            this.generateBtn.TabIndex = 9;
            this.generateBtn.Text = "Generate a new tree";
            this.generateBtn.UseVisualStyleBackColor = true;
            this.generateBtn.Click += new System.EventHandler(this.generateBtn_Click);
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.generateBtn);
            this.panel1.Controls.Add(this.modeBtn);
            this.panel1.Location = new System.Drawing.Point(450, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(169, 167);
            this.panel1.TabIndex = 10;
            // 
            // TreeForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1069, 1068);
            this.Controls.Add(this.angleVariationSlider);
            this.Controls.Add(this.angleDeltaSlider);
            this.Controls.Add(this.thirdProbabilitySlider);
            this.Controls.Add(this.distanceVariationSlider);
            this.Controls.Add(this.timeSlider);
            this.Controls.Add(this.offsetSlider);
            this.Controls.Add(this.heightSlider);
            this.Controls.Add(this.ratioSlider);
            this.Controls.Add(this.panel1);
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "TreeForm";
            this.Text = "Tree";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.angleDeltaSlider)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.ratioSlider)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.offsetSlider)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.heightSlider)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.timeSlider)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.distanceVariationSlider)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.angleVariationSlider)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.thirdProbabilitySlider)).EndInit();
            this.panel1.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TrackBar angleDeltaSlider;
        private System.Windows.Forms.TrackBar ratioSlider;
        private System.Windows.Forms.TrackBar offsetSlider;
        private System.Windows.Forms.TrackBar heightSlider;
        private System.Windows.Forms.TrackBar timeSlider;
        private System.Windows.Forms.TrackBar distanceVariationSlider;
        private System.Windows.Forms.TrackBar angleVariationSlider;
        private System.Windows.Forms.TrackBar thirdProbabilitySlider;
        private System.Windows.Forms.Button modeBtn;
        private System.Windows.Forms.Button generateBtn;
        private System.Windows.Forms.Panel panel1;
    }
}

