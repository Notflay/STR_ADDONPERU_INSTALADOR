namespace STR_ADDONPERU_INSTALADOR
{
    partial class Login
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Login));
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.materialButton11 = new MaterialSkin.Controls.MaterialButton();
            this.edtPassDB = new System.Windows.Forms.TextBox();
            this.edtPassS = new System.Windows.Forms.TextBox();
            this.edtNombreDB = new System.Windows.Forms.TextBox();
            this.edtServidor = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.materialLabel1 = new MaterialSkin.Controls.MaterialLabel();
            this.pictureBox2 = new System.Windows.Forms.PictureBox();
            this.label5 = new System.Windows.Forms.Label();
            this.edtUsuarioDB = new System.Windows.Forms.TextBox();
            this.label6 = new System.Windows.Forms.Label();
            this.edtUsuarioS = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.cbxTipoDB = new System.Windows.Forms.ComboBox();
            this.chkVerPass = new System.Windows.Forms.CheckBox();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).BeginInit();
            this.SuspendLayout();
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::STR_ADDONPERU_INSTALADOR.Properties.Resources.ramologo;
            this.pictureBox1.Location = new System.Drawing.Point(367, 101);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(113, 81);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox1.TabIndex = 29;
            this.pictureBox1.TabStop = false;
            this.pictureBox1.Click += new System.EventHandler(this.pictureBox1_Click);
            // 
            // materialButton11
            // 
            this.materialButton11.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.materialButton11.Density = MaterialSkin.Controls.MaterialButton.MaterialButtonDensity.Default;
            this.materialButton11.Depth = 0;
            this.materialButton11.HighEmphasis = true;
            this.materialButton11.Icon = null;
            this.materialButton11.Location = new System.Drawing.Point(367, 403);
            this.materialButton11.Margin = new System.Windows.Forms.Padding(4, 6, 4, 6);
            this.materialButton11.MouseState = MaterialSkin.MouseState.HOVER;
            this.materialButton11.Name = "materialButton11";
            this.materialButton11.NoAccentTextColor = System.Drawing.Color.Empty;
            this.materialButton11.Size = new System.Drawing.Size(88, 36);
            this.materialButton11.TabIndex = 28;
            this.materialButton11.Text = "Guardar";
            this.materialButton11.Type = MaterialSkin.Controls.MaterialButton.MaterialButtonType.Contained;
            this.materialButton11.UseAccentColor = false;
            this.materialButton11.UseVisualStyleBackColor = true;
            this.materialButton11.Click += new System.EventHandler(this.materialButton11_Click);
            // 
            // edtPassDB
            // 
            this.edtPassDB.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.edtPassDB.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.edtPassDB.Location = new System.Drawing.Point(336, 291);
            this.edtPassDB.Name = "edtPassDB";
            this.edtPassDB.PasswordChar = '*';
            this.edtPassDB.Size = new System.Drawing.Size(169, 21);
            this.edtPassDB.TabIndex = 26;
            // 
            // edtPassS
            // 
            this.edtPassS.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.edtPassS.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.edtPassS.Location = new System.Drawing.Point(336, 372);
            this.edtPassS.Name = "edtPassS";
            this.edtPassS.Size = new System.Drawing.Size(169, 21);
            this.edtPassS.TabIndex = 24;
            this.edtPassS.TextChanged += new System.EventHandler(this.txtUsuario_TextChanged);
            // 
            // edtNombreDB
            // 
            this.edtNombreDB.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.edtNombreDB.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.edtNombreDB.Location = new System.Drawing.Point(336, 231);
            this.edtNombreDB.Name = "edtNombreDB";
            this.edtNombreDB.Size = new System.Drawing.Size(169, 21);
            this.edtNombreDB.TabIndex = 22;
            // 
            // edtServidor
            // 
            this.edtServidor.BackColor = System.Drawing.SystemColors.Window;
            this.edtServidor.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.edtServidor.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.edtServidor.Location = new System.Drawing.Point(336, 201);
            this.edtServidor.Name = "edtServidor";
            this.edtServidor.Size = new System.Drawing.Size(169, 21);
            this.edtServidor.TabIndex = 20;
            this.edtServidor.Tag = "";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Corbel", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(209, 291);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(100, 18);
            this.label4.TabIndex = 27;
            this.label4.Text = "Contraseña DB";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Corbel", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(209, 348);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(85, 18);
            this.label3.TabIndex = 25;
            this.label3.Text = "Usuario SAP";
            this.label3.Click += new System.EventHandler(this.label3_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Corbel", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(209, 233);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(121, 18);
            this.label2.TabIndex = 23;
            this.label2.Text = "Nombre de la Base";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Corbel", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(209, 201);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(96, 18);
            this.label1.TabIndex = 21;
            this.label1.Text = "IP del Servidor";
            // 
            // materialLabel1
            // 
            this.materialLabel1.AutoSize = true;
            this.materialLabel1.Depth = 0;
            this.materialLabel1.Font = new System.Drawing.Font("Roboto", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Pixel);
            this.materialLabel1.FontType = MaterialSkin.MaterialSkinManager.fontType.Caption;
            this.materialLabel1.Location = new System.Drawing.Point(585, 425);
            this.materialLabel1.MouseState = MaterialSkin.MouseState.HOVER;
            this.materialLabel1.Name = "materialLabel1";
            this.materialLabel1.Size = new System.Drawing.Size(154, 14);
            this.materialLabel1.TabIndex = 30;
            this.materialLabel1.Text = "Desarrollado por Ramo Perú";
            // 
            // pictureBox2
            // 
            this.pictureBox2.Image = global::STR_ADDONPERU_INSTALADOR.Properties.Resources.ramologo;
            this.pictureBox2.Location = new System.Drawing.Point(745, 418);
            this.pictureBox2.Name = "pictureBox2";
            this.pictureBox2.Size = new System.Drawing.Size(27, 29);
            this.pictureBox2.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox2.TabIndex = 31;
            this.pictureBox2.TabStop = false;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Corbel", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(209, 262);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(77, 18);
            this.label5.TabIndex = 32;
            this.label5.Text = "Usuario DB";
            // 
            // edtUsuarioDB
            // 
            this.edtUsuarioDB.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.edtUsuarioDB.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.edtUsuarioDB.Location = new System.Drawing.Point(336, 259);
            this.edtUsuarioDB.Name = "edtUsuarioDB";
            this.edtUsuarioDB.Size = new System.Drawing.Size(169, 21);
            this.edtUsuarioDB.TabIndex = 33;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Font = new System.Drawing.Font("Corbel", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label6.Location = new System.Drawing.Point(209, 375);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(108, 18);
            this.label6.TabIndex = 34;
            this.label6.Text = "Contraseña SAP";
            // 
            // edtUsuarioS
            // 
            this.edtUsuarioS.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.edtUsuarioS.Font = new System.Drawing.Font("Arial", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.edtUsuarioS.Location = new System.Drawing.Point(336, 345);
            this.edtUsuarioS.Name = "edtUsuarioS";
            this.edtUsuarioS.Size = new System.Drawing.Size(169, 21);
            this.edtUsuarioS.TabIndex = 35;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Font = new System.Drawing.Font("Corbel", 11.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label7.Location = new System.Drawing.Point(209, 321);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(57, 18);
            this.label7.TabIndex = 36;
            this.label7.Text = "Tipo DB";
            this.label7.Click += new System.EventHandler(this.label7_Click);
            // 
            // cbxTipoDB
            // 
            this.cbxTipoDB.FormattingEnabled = true;
            this.cbxTipoDB.Items.AddRange(new object[] {
            "HANADB",
            "MSSQL2008",
            "MSSQL2012",
            "MSSQL2014",
            "MSSQL2016",
            "MSSQL2017"});
            this.cbxTipoDB.Location = new System.Drawing.Point(336, 319);
            this.cbxTipoDB.Name = "cbxTipoDB";
            this.cbxTipoDB.Size = new System.Drawing.Size(169, 21);
            this.cbxTipoDB.TabIndex = 37;
            // 
            // chkVerPass
            // 
            this.chkVerPass.AutoSize = true;
            this.chkVerPass.Location = new System.Drawing.Point(511, 293);
            this.chkVerPass.Name = "chkVerPass";
            this.chkVerPass.Size = new System.Drawing.Size(15, 14);
            this.chkVerPass.TabIndex = 38;
            this.chkVerPass.UseVisualStyleBackColor = true;
            this.chkVerPass.CheckedChanged += new System.EventHandler(this.chkVerPass_CheckedChanged);
            // 
            // Login
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.chkVerPass);
            this.Controls.Add(this.cbxTipoDB);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.edtUsuarioS);
            this.Controls.Add(this.label6);
            this.Controls.Add(this.edtUsuarioDB);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.pictureBox2);
            this.Controls.Add(this.materialLabel1);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.materialButton11);
            this.Controls.Add(this.edtPassDB);
            this.Controls.Add(this.edtPassS);
            this.Controls.Add(this.edtNombreDB);
            this.Controls.Add(this.edtServidor);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Login";
            this.Text = "Login";
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox2)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox pictureBox1;
        private MaterialSkin.Controls.MaterialButton materialButton11;
        private System.Windows.Forms.TextBox edtPassDB;
        private System.Windows.Forms.TextBox edtPassS;
        private System.Windows.Forms.TextBox edtNombreDB;
        private System.Windows.Forms.TextBox edtServidor;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;

        private MaterialSkin.Controls.MaterialLabel materialLabel1;
        private System.Windows.Forms.PictureBox pictureBox2;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox edtUsuarioDB;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox edtUsuarioS;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.ComboBox cbxTipoDB;
        private System.Windows.Forms.CheckBox chkVerPass;
    }
}