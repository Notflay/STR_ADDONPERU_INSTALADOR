﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
using MaterialSkin;
using MaterialSkin.Controls;
using SAPbobsCOM;
using SAPbouiCOM;


namespace STR_ADDONPERU_INSTALADOR
{
    public partial class FrmInstalador : MaterialForm
    {
        private readonly MaterialSkin.MaterialSkinManager materialSkinManager;
        private MaterialProgressBar progressBar;
        private MaterialLabel lblInstalador;
        private MaterialButton btnInstalador;
        private SAPbobsCOM.Company company;
        private SAPbouiCOM.Application application;
        int validados = 0;
        int faltantes = 0;
        int totales = 0;
        public FrmInstalador(SAPbobsCOM.Company company, SAPbouiCOM.Application application)
        {
            InitializeComponent();
            materialSkinManager = MaterialSkin.MaterialSkinManager.Instance;
            materialSkinManager.EnforceBackcolorOnAllComponents = true;
            materialSkinManager.AddFormToManage(this);
            materialSkinManager.Theme = MaterialSkin.MaterialSkinManager.Themes.LIGHT;
            materialSkinManager.ColorScheme = new MaterialSkin.ColorScheme(MaterialSkin.Primary.Green500, MaterialSkin.Primary.Green700, MaterialSkin.Primary.LightGreen100, MaterialSkin.Accent.Green700, MaterialSkin.TextShade.WHITE);

            this.company = company;
            this.application = application;
        }

        private void FrmInstalador_Load(object sender, EventArgs e)
        {

        }

        private void tabPage3_Click(object sender, EventArgs e)
        {

        }

        private void materialLabel1_Click(object sender, EventArgs e)
        {

        }

        private void tabPage1_Click(object sender, EventArgs e)
        {

        }

        private void materialButton11_Click(object sender, EventArgs e)
        {

        }

        private void txtPassword_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtUsuario_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtNombre_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtServidor_TextChanged(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void lblDetalle_Click(object sender, EventArgs e)
        {

        }

        private void materialButton1_Click(object sender, EventArgs e)
        {




        }

        private void materialButton11_Click_1(object sender, EventArgs e)
        {

        }

        private void materialTabControl1_SelectedIndexChanged(object sender, EventArgs e)
        {

            validados = 0;
            faltantes = 0;
            totales = 0;

            int position = materialTabControl1.SelectedIndex;
            switch (position)
            {
                case 0:
                    progressBar = pbLocalizacion;
                    lblInstalador = lblLocalizacion;
                    sbCargaConteo("Localizacion");
                    break;
                case 1:
                    progressBar = pbSire;
                    lblInstalador = lblSire;
                    sbCargaConteo("SIRE");
                    break;
                case 2:
                    progressBar = pbEar;
                    lblInstalador = lblCajEar;
                    sbCargaConteo("CCHHE");
                    break;
                case 3:
                    progressBar = pbLetras;
                    lblInstalador = lblLetras;
                    sbCargaConteo("Letra");
                    break;
                default:
                    break;
            }
        }
        public void sbCargaConteo(string addon)
        {
            sbConteoCarga(addon);
            int porcentaje = promedioPorcentaje();
            lblInstalador.Text = $"Descarga ({porcentaje}%)";
            progressBar.Increment(porcentaje);
        }

        public int promedioPorcentaje()
        {
            int valor = validados / totales * 100;
            return valor;
        }

        public void sbConteoCarga(string addon)
        {
         

            string path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\UT.vte";
            totales += company.GetXMLelementCount(path);

            path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\UF.vte";
            totales += company.GetXMLelementCount(path);

            path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\UO.vte";
            totales += company.GetXMLelementCount(path);

        }

        public void sbConteoColumnas(string addon)
        {
            string path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\UF.vte";
            XmlDocument xdoc = new XmlDocument();
            xdoc.Load(path);


            XmlNodeList tableNameNodes = xdoc.SelectNodes("//UserFieldsMD/row");
            foreach (XmlNode tableNameNode in tableNameNodes)
            {
                UserFieldsMD userFieldsMD = (UserFieldsMD)company.GetBusinessObject(BoObjectTypes.oUserFields);
                string tableName = tableNameNode.SelectSingleNode("TableName")?.InnerText;
                string name = tableNameNode.SelectSingleNode("Name")?.InnerText;
                /*
                for (int i = 0; i < userFieldsMD.Fields.C; i++)
                {

                }*/
            }
        }



        public void sbConteObjetos(string addon)
        {
            string path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\UF.vte";
            XmlDocument xdoc = new XmlDocument();
            xdoc.Load(path);


            XmlNodeList tableNameNodes = xdoc.SelectNodes("//UserFieldsMD/row");
            foreach (XmlNode tableNameNode in tableNameNodes)
            {
                UserFieldsMD userFieldsMD = (UserFieldsMD)company.GetBusinessObject(BoObjectTypes.oUserFields);
                string tableName = tableNameNode.SelectSingleNode("TableName")?.InnerText;
                string name = tableNameNode.SelectSingleNode("Name")?.InnerText;
                /*
                for (int i = 0; i < userFieldsMD.Fields.C; i++)
                {

                }
*/
            }
        }

    }
}
