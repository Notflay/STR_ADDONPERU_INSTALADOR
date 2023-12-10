using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Windows.Interop;
using System.Xml;
using MaterialSkin;
using MaterialSkin.Controls;
using SAPbobsCOM;
using SAPbouiCOM;
using STR_ADDONPERU_INSTALADOR.Util;

namespace STR_ADDONPERU_INSTALADOR
{
    public partial class FrmInstalador : MaterialForm
    {
        private readonly MaterialSkin.MaterialSkinManager materialSkinManager;
        private MaterialProgressBar progressBar;
        private MaterialLabel lblInstalador;
        private MaterialButton btnInstalador;
        private MaterialLabel lblDescription;
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
            createElements("Localizacion");



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
                    lblDescription = lblLocaDesc;
                    sbConteoCargaInit("Localizacion");
                    sbCargaConteo();
                    break;
                case 1:
                    progressBar = pbSire;
                    lblInstalador = lblSire;
                    lblDescription = lblSrDesc;
                    sbConteoCargaInit("SIRE");
                    sbCargaConteo();
                    break;
                case 2:
                    progressBar = pbEar;
                    lblInstalador = lblCajEar;
                    lblDescription = lblCcEDesc;
                    sbConteoCargaInit("CCHHE");
                    sbCargaConteo();
                    break;
                case 3:
                    progressBar = pbLetras;
                    lblInstalador = lblLetras;
                    lblDescription = lblLetrasDesc;
                    sbConteoCargaInit("Letras");
                    sbCargaConteo();
                    break;
                default:
                    break;
            }
        }
        public void sbCargaConteo()
        {
            int porcentaje = promedioPorcentaje();
            lblInstalador.Text = $"Descarga ({porcentaje}%)";

            progressBar.Increment(porcentaje);
        }

        public int promedioPorcentaje()
        {
            double valor = ((double)validados / totales) * 100;
            int valorFinal = (int)Math.Round(valor);
            return valorFinal;
        }

        public void sbConteoCargaInit(string addon)
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

        private void createElements(string addon)
        {
            SAPbobsCOM.Company companyAux = null;
            string pathFile = string.Empty;
            int cntElementos = 0;
            int cntErrores = 0;
            int cntExistentes = 0;
            dynamic elementoMD;

           
            try
            {
                companyAux = application.Company.GetDICompany();
                string[] elements = { "UT", "UF", "UO" };
                GC.Collect();
                GC.WaitForPendingFinalizers();
                elements.ToList().ForEach(e =>
                {
                    var tipoElemento = (e.Equals("UT") ? " Tabla " : e.Equals("UT") ? "Objeto " : "Campo");
                    Cursor.Current = Cursors.WaitCursor;

                    pathFile = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\{e}.vte";


                    if (!File.Exists(pathFile)) throw new FileNotFoundException();
                    cntElementos = companyAux.GetXMLelementCount(pathFile);
                    for (int i = 0; i < cntElementos; i++)
                    {
                        try
                        {
                            elementoMD = companyAux.GetBusinessObjectFromXML(pathFile, i);
                            string mensaje = $"Creando {tipoElemento.Replace('s', ' ')} {(e.Equals("UT") | e.Equals("UO") ? "" : $"{elementoMD.Name} de la tabla: ")} {elementoMD.TableName}";
                            lblDescription.Text = mensaje;
                            string nameElemento = e == "UT" ? elementoMD.TableName : e == "UF" ? elementoMD.Name : elementoMD.Code;

                            if (elementoMD.Add() != 0)
                            {
                                companyAux.GetLastError(out int codigoErr, out string descripErr);
                                if (codigoErr != -2035 && codigoErr != -5002)
                                {
                                    cntErrores++;
                                    validados--;
                                    Global.WriteToFile($"Error al instalar compemento de {addon} - {tipoElemento} {nameElemento} - {codigoErr} - {descripErr}");
                                }
                                else if (codigoErr == -2035)
                                {
                                    string msj = $"Ya existe en SAP componente {tipoElemento.Replace('s', ' ')} {(e.Equals("UT") | e.Equals("UO") ? "" : $"{elementoMD.Name} de la tabla: ")} {elementoMD.TableName}";
                                    lblDescription.Text = msj;
                                    cntExistentes++;
                                    Global.WriteToFile(msj);
                                }
                            }
                            else
                            {
                                string msj = $"Se creo exitosamente en SAP {tipoElemento.Replace('s', ' ')} {(e.Equals("UT") | e.Equals("UO") ? "" : $"{elementoMD.Name} de la tabla: ")} {elementoMD.TableName}";
                                Global.WriteToFile(msj);
                                lblDescription.Text = msj;
                            }
                            validados++;
                            sbCargaConteo();
                            System.Runtime.InteropServices.Marshal.ReleaseComObject(elementoMD);
                            GC.Collect();
                        }
                        catch (Exception ex)
                        {
                            //sboApplication.statusBarErrorMsg(ex.Message);
                            Global.WriteToFile($"Error al instalar complementos " + ex.Message);

                        }
                        finally
                        {
                            elementoMD = null;
                        }
                    }
                    //if (cntErrores == 0) sboApplication.statusBarSuccessMsg($"{tipoElemento} de usuario creados correctamente");
                    Cursor.Current = Cursors.Default;
                });
            }
            catch { throw; }
            finally
            {
                if (validados == totales)
                {
                    if (validados - cntExistentes == 0)
                        MessageBox.Show($"Se valido que ya existen todos los {validados} complementos para el Addin", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    else
                        MessageBox.Show($"Se crearon {validados - cntExistentes} {(cntExistentes > 0 ? $"y se validaron {cntExistentes} ya existentes" : "")} complementos para el Addin", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show($"No se llegaron a crear todos los complementos, se tuvo {cntErrores} errores, solo se llegaron a crear {validados - cntExistentes} complementos para el Addin. Revisar en Logs mas detalle", "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }

                lblDescription.Text = "";
            }
        }

        private void btnInstSire_Click(object sender, EventArgs e)
        {
            createElements("SIRE");
        }

        private void btnInstEar_Click(object sender, EventArgs e)
        {
            createElements("CCHE");
        }

        private void btnInstLetra_Click(object sender, EventArgs e)
        {
            createElements("Letras");
        }

        private void materialButton9_Click(object sender, EventArgs e)
        {
            string path = $"{AppDomain.CurrentDomain.BaseDirectory}\\Logs\\Service_Creation_Log_{DateTime.Now.Date.ToShortDateString().Replace('/', '_')}.txt";

            string contenido= File.ReadAllText(path);

           

        }
    }
}
