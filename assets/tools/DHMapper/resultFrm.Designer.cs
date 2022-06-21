namespace DHMapper
{
    partial class resultFrm
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
            this.resultText = new System.Windows.Forms.RichTextBox();
            this.copyBtn = new System.Windows.Forms.Button();
            this.cerrarBtn = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // resultText
            // 
            this.resultText.Location = new System.Drawing.Point(12, 31);
            this.resultText.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.resultText.Name = "resultText";
            this.resultText.Size = new System.Drawing.Size(755, 480);
            this.resultText.TabIndex = 0;
            this.resultText.Text = "";
            // 
            // copyBtn
            // 
            this.copyBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.copyBtn.Location = new System.Drawing.Point(12, 516);
            this.copyBtn.Name = "copyBtn";
            this.copyBtn.Size = new System.Drawing.Size(173, 23);
            this.copyBtn.TabIndex = 1;
            this.copyBtn.Text = "Copiar al Portapapeles";
            this.copyBtn.UseVisualStyleBackColor = true;
            this.copyBtn.Click += new System.EventHandler(this.copyBtn_Click);
            // 
            // cerrarBtn
            // 
            this.cerrarBtn.BackColor = System.Drawing.Color.Red;
            this.cerrarBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.cerrarBtn.ForeColor = System.Drawing.SystemColors.ButtonHighlight;
            this.cerrarBtn.Location = new System.Drawing.Point(594, 516);
            this.cerrarBtn.Name = "cerrarBtn";
            this.cerrarBtn.Size = new System.Drawing.Size(173, 23);
            this.cerrarBtn.TabIndex = 2;
            this.cerrarBtn.Text = "Cerrar";
            this.cerrarBtn.UseVisualStyleBackColor = false;
            this.cerrarBtn.Click += new System.EventHandler(this.cerrarBtn_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 14);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(92, 15);
            this.label1.TabIndex = 3;
            this.label1.Text = "Generated Code";
            // 
            // resultFrm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(779, 550);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.cerrarBtn);
            this.Controls.Add(this.copyBtn);
            this.Controls.Add(this.resultText);
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.Name = "resultFrm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Result Code";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private RichTextBox resultText;
        private Button copyBtn;
        private Button cerrarBtn;
        private Label label1;
    }
}