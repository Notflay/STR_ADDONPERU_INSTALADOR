using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml.Linq;
using MaterialSkin.Controls;
using Microsoft.Office.Interop.Excel;
using SAPbobsCOM;
using STR_ADDONPERU_INSTALADOR.Util;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;
using Global = STR_ADDONPERU_INSTALADOR.Util.Global;
using ms = Microsoft.Office.Interop.Excel; 

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
        private SAPbobsCOM.Company companyRS;
        private string addon;
        private bool isRunning = false;
        int validados = 0;
        int faltantes = 0;
        int totales = 0;
        int totalElementos = 0;
        public FrmInstalador(SAPbobsCOM.Company company)
        {
            InitializeComponent();
            InicializarLabelComun();
            materialSkinManager = MaterialSkin.MaterialSkinManager.Instance;
            materialSkinManager.EnforceBackcolorOnAllComponents = true;
            materialSkinManager.AddFormToManage(this);
            materialSkinManager.Theme = MaterialSkin.MaterialSkinManager.Themes.LIGHT;
            materialSkinManager.ColorScheme = new MaterialSkin.ColorScheme(MaterialSkin.Primary.Green500, MaterialSkin.Primary.Green700, MaterialSkin.Primary.LightGreen100, MaterialSkin.Accent.Green700, MaterialSkin.TextShade.WHITE);

            this.company = company;
            lblNameDB.Text = "Conectado a " + company.CompanyDB;
            lblnameEar.Text = "Conectado a " + company.CompanyDB;
            lblnameLetr.Text = "Conectado a " + company.CompanyDB;
            lblnomSir.Text = "Conectado a " + company.CompanyDB;
        }

        private void InicializarLabelComun()
        {

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
            ValidaBtn(0, "Localizacion");

        }
        private void btnInstSire_Click(object sender, EventArgs e)
        {
            ValidaBtn(1, "SIRE");
        }

        private void btnInstEar_Click(object sender, EventArgs e)
        {
            ValidaBtn(2, "CCHHE");
        }

        private void btnInstLetra_Click(object sender, EventArgs e)
        {
            ValidaBtn(3, "Letras");
        }

        private void ValidaBtn(int posiAdd, string addon)
        {
            if (isRunning)
                StopLoading();
            else
            {
                materialTabControl1.SelectedIndex = posiAdd;
                setControlTab();

                StartLoading(addon);
            }
        }

        private void StopLoading()
        {
            isRunning = false;
            // Puedes realizar acciones adicionales de limpieza si es necesario

            // Restablece la apariencia del botón
            btnInstalador.Text = "Instalar Complementos";
        }

        private void StartLoading(string addon)
        {
            isRunning = true;
            btnInstalador.Text = "Detener instalación";

            // Usa un hilo separado para realizar la carga y mantener la interfaz de usuario receptiva
            Task.Run(() =>
            {
                instalaComplementos(addon);

                // La carga ha terminado, restablece la bandera
                isRunning = false;
                this.Invoke((MethodInvoker)delegate
                {
                    btnInstalador.Text = "Instalar Complementos";
                });
            });
        }

        private void materialButton11_Click_1(object sender, EventArgs e)
        {

        }

        private void materialTabControl1_SelectedIndexChanged(object sender, EventArgs e)
        {

            validados = 0;
            faltantes = 0;
            totales = 0;
            totalElementos = 0;
            //setControlTab();
        }

        public void setControlTab()
        {
            int position = materialTabControl1.SelectedIndex;
            switch (position)
            {
                case 0:
                    progressBar = pbLocalizacion;
                    lblInstalador = lblLocalizacion;
                    lblDescription = lblLocaDesc;
                    btnInstalador = btnInstLoca;
                    sbConteoCargaInit("Localizacion");
                    sbCargaConteo();
                    break;
                case 1:
                    progressBar = pbSire;
                    lblInstalador = lblSire;
                    lblDescription = lblSrDesc;
                    btnInstalador = btnInstSire;
                    sbConteoCargaInit("SIRE");
                    sbCargaConteo();
                    break;
                case 2:
                    progressBar = pbEar;
                    lblInstalador = lblCajEar;
                    btnInstalador = btnInstEar;
                    lblDescription = lblCcEDesc;
                    sbConteoCargaInit("CCHHE");
                    sbCargaConteo();
                    break;
                case 3:
                    progressBar = pbLetras;
                    btnInstalador = btnInstLetra;
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
            this.Invoke((MethodInvoker)delegate
            {
                int porcentaje = promedioPorcentaje();
                lblInstalador.Text = $"Descarga ({porcentaje}%)";

                // Establecer el valor absoluto en lugar de incrementar
                progressBar.Value = porcentaje;
            });
        }

        public int promedioPorcentaje()
        {
            double valor = ((double)validados / totales) * 100;
            int valorFinal = (int)Math.Round(valor);

            // Asegúrate de que el valor esté dentro del rango de la barra de progreso
            valorFinal = Math.Min(Math.Max(valorFinal, progressBar.Minimum), progressBar.Maximum);

            return valorFinal;
        }

        public bool tableExis(string tabla, string element, dynamic elementMD, ref int cntExistentes)
        {
            SAPbobsCOM.Recordset rs = company.GetBusinessObject(BoObjectTypes.BoRecordset);
            try
            {
                rs.DoQuery($"SELECT TOP 1 * FROM \"@{tabla}\"");
                string tipoElement = GetElementTypeDescription(element);
                validados++;
                HandleAddExist(element, tipoElement, elementMD, ref cntExistentes);
                return true;
            }
            catch (Exception)
            {

                return false;
            }
            finally
            {
                rs = null;
            }
        }

        public bool columnExis(string campo, string tabla, string element, dynamic elementMD, ref int cntExistentes)
        {
            SAPbobsCOM.Recordset rs = company.GetBusinessObject(BoObjectTypes.BoRecordset);

            try
            {

                rs.DoQuery($"SELECT TOP 1 \"U_{campo}\" FROM \"{tabla}\"");
                string tipoElement = GetElementTypeDescription(element);
                validados++;
                HandleAddExist(element, tipoElement, elementMD, ref cntExistentes);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
            finally
            {
                rs = null;
            }
        }

        public void instalaComplementos(string addon)
        {
            try
            {
                if (isRunning)
                {

                    CreateElementsNew(addon);

                    // Crear La tabla Type
                    if (addon == "Localizacion" & company.DbServerType == BoDataServerTypes.dst_HANADB) {
                        try
                        {
                            string[] lo_ArrFiles = null;
                            string ls_Path = System.Windows.Forms.Application.StartupPath + $"\\Resources\\{addon}";
                            System.IO.StreamReader lo_StrmRdr = null;
                            // Ubicación de la tabla TYPE
                            string ls_StrFile = string.Empty;
                            lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Types\", "*.sql");

                            SAPbobsCOM.Recordset lo_RecSet = null;
                            lo_RecSet = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);

                            for (int i = 0; i < lo_ArrFiles.GetUpperBound(0) + 1; i++)
                            {
                                lo_StrmRdr = new System.IO.StreamReader(lo_ArrFiles[i]);
                                ls_StrFile = lo_StrmRdr.ReadToEnd();


                                lo_RecSet.DoQuery(ls_StrFile);
                            }
                        }
                        catch (Exception)
                        {

                        }
                    }
                    if (MessageBox.Show("¿Deseas continuar con la creación de procedimientos?", "Scripts", MessageBoxButtons.YesNo, MessageBoxIcon.Information) == DialogResult.Yes)
                    {
                        fn_createProcedures(addon);

                        if (addon == "Letras" | addon == "CCHHE" | addon == "SIRE" | addon == "Localizacion")
                        {
                            if (MessageBox.Show("¿Deseas continuar con la inicialización de la configuración?", "Scripts", MessageBoxButtons.YesNo, MessageBoxIcon.Information) == DialogResult.Yes)
                            {
                                fn_inicializacion(addon);
                            }
                            else
                            {
                                MessageBox.Show("Se terminó con la creación de los scripts", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                                Global.WriteToFile($"{addon}: Se terminó con la creación de los scripts");
                            }
                        }
                        else
                        {
                            MessageBox.Show("Se terminó con la creación de los scripts", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            Global.WriteToFile($"{addon}: Se terminó con la creación de los scripts");
                        }
                    }
                    else
                    {
                        MessageBox.Show("Se terminó con la creación de los campos y tablas", "Finalizado", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }

                }

            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                validados = 0;
                faltantes = 0;
                totales = 0;
                totalElementos = 0;
            }
        }

        private void CreateElementsNew(string addon)
        {
            string pathFile = string.Empty;

            int cntErrores = 0;
            int cntExistentes = 0;
            List<int> elemtsProcesar = new List<int>();

            try
            {

                string[] elements = { "UT", "UF", "UO" };
                GC.Collect();
                GC.WaitForPendingFinalizers();
                elements.ToList().ForEach(e =>
                {
                    if (isRunning)
                    {
                        //Cursor.Current = Cursors.WaitCursor;
                        pathFile = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\{e}.vte";
                        if (!File.Exists(pathFile)) throw new FileNotFoundException();

                        InsertElementosProcess(pathFile, e, ref elemtsProcesar, e, ref cntExistentes);

                        GC.Collect();
                        GC.WaitForPendingFinalizers();

                        ProcessElementsOfType(pathFile, e, ref cntErrores, ref cntExistentes, ref elemtsProcesar);
                    }
                });
            }
            catch { throw; }
            finally
            {
                this.Invoke((MethodInvoker)delegate
                {
                    DisplayFinalMessage(cntErrores, cntExistentes);
                    lblDescription.Text = "";
                });
            }
        }

        private void InsertElementosProcess(string pathFile, string e, ref List<int> elemtsProcesar, string element, ref int cntExistentes)
        {
            SAPbobsCOM.Company companyAux = null;
            companyAux = this.company;
            try
            {
                int cntElementos = companyAux.GetXMLelementCount(pathFile);
                for (int i = 0; i < cntElementos; i++)
                {
                    if (isRunning)
                    {
                        dynamic elemtoMD = null;
                        try
                        {
                            elemtoMD = companyAux.GetBusinessObjectFromXML(pathFile, i);
                            bool exis = e == "UT" ? tableExis(elemtoMD.TableName, element, elemtoMD, ref cntExistentes) : e == "UF" ?
                                columnExis(elemtoMD.Name, elemtoMD.TableName, element, elemtoMD, ref cntExistentes) : false;
                            if (!exis) elemtsProcesar.Add(i);

                        }
                        catch (Exception)
                        {
                            throw;
                        }
                        finally
                        {
                            elemtoMD = null;
                        }
                    }
                }
            }
            finally
            {
                companyAux = null;
            }
        }
        public void sbConteoCargaInit(string addon)
        {
            string[] lo_ArrFiles = null;

            string path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\UT.vte";
            totales += company.GetXMLelementCount(path);
            totalElementos += company.GetXMLelementCount(path);

            path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\UF.vte";
            totales += company.GetXMLelementCount(path);
            totalElementos += company.GetXMLelementCount(path);

            path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\UO.vte";
            totales += company.GetXMLelementCount(path);
            totalElementos += company.GetXMLelementCount(path);

            string ls_Path = System.Windows.Forms.Application.StartupPath + $"\\Resources\\{addon}";

            if (company.DbServerType == BoDataServerTypes.dst_HANADB)
            {
                lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Scripts\HANA\", "*.sql");
            }
            else
            {
                lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Scripts\SQL\", "*.sql");
            }

            totales += lo_ArrFiles.Count();
        }

        private void ProcessElementsOfType(string pathFile, string element, ref int cntErrores, ref int cntExistentes, ref List<int> elemtsProcesar)
        {
            SAPbobsCOM.Company companyAux = null;
            int cntElementos = 0;
            companyAux = this.company;

            try
            {
                //cntElementos = company.GetXMLelementCount(pathFile);
                //for (int i = 0; i < cntElementos; i++)
                for (int i = 0; i < elemtsProcesar.Count; i++)
                {
                    dynamic elementoMD = null;
                    try
                    {
                        string tipoElemento = GetElementTypeDescription(element);
                        //elementoMD = companyAux.GetBusinessObjectFromXML(pathFile, i);
                        elementoMD = companyAux.GetBusinessObjectFromXML(pathFile, elemtsProcesar[i]);
                        string mensaje = $"Creando {tipoElemento.Replace('s', ' ')} {(element.Equals("UT") | element.Equals("UO") ? "" : $"{elementoMD.Name} de la tabla: ")} {elementoMD.TableName}";
                        this.Invoke((MethodInvoker)delegate
                        {
                            lblDescription.Text = mensaje;
                        });

                        ProcessNewElement(elementoMD, element, tipoElemento, ref cntErrores, ref cntExistentes);


                    }
                    catch (Exception ex)
                    {
                        Global.WriteToFile($"{addon}: ERROR al instalar complementos " + ex.Message);
                    }
                    finally
                    {
                        elementoMD = null;
                    }
                }
            }
            finally
            {
                elemtsProcesar.Clear();
                //Cursor.Current = Cursors.Default;
            }

        }

        private string GetElementTypeDescription(string elementType)
        {
            return elementType.Equals("UT") ? "Tabla" : elementType.Equals("UF") ? "Campo" : "Objeto";
        }
        private void DisplayFinalMessage(int cntErrores, int cntExistentes)
        {
            if (validados == totalElementos)
            {
                if (validados - cntExistentes == 0)
                    MessageBox.Show($"Se validó que ya existen todos los {validados} complementos para el Addin", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                else
                    MessageBox.Show($"Se crearon {validados - cntExistentes} {(cntExistentes > 0 ? $"y se validaron {cntExistentes} ya existentes" : "")} complementos para el Addin", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            else
            {
                MessageBox.Show($"No se llegaron a crear todos los complementos, se tuvo {cntErrores} errores, solo se llegaron a crear {validados - cntExistentes} complementos para el Addin. Revisar en Logs mas detalle", "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void ProcessNewElement(dynamic elementoMD, string element, string tipoElemento, ref int cntErrores, ref int cntExistentes)
        {

            if (elementoMD.Add() == 0)
            {
                HandleAddSuccess(element, tipoElemento, elementoMD);
            }
            else
            {
                HandleAddError(element, tipoElemento, elementoMD, ref cntErrores, ref cntExistentes);
            }
            System.Runtime.InteropServices.Marshal.ReleaseComObject(elementoMD);
            GC.Collect();
        }

        private void HandleAddSuccess(string element, string tipoElemento, dynamic elementoMD)
        {
            this.Invoke((MethodInvoker)delegate
            {
                string msj = $"{addon}: Se creo exitosamente en SAP {tipoElemento.Replace('s', ' ')} {(element.Equals("UT") | element.Equals("UO") ? "" : $"{elementoMD.Name} de la tabla: ")} {elementoMD.TableName}";
                lblDescription.Text = msj;
                Global.WriteToFile(msj);
                validados++;
                sbCargaConteo();
            });
        }
        private void HandleAddExist(string element, string tipoElemento, dynamic elementMD, ref int cntExistentes)
        {
            string msj = $"{addon}: Ya existe en SAP complemento {tipoElemento.Replace('s', ' ')} {(element.Equals("UT") | element.Equals("UO") ? "" : $"{elementMD.Name} de la tabla: ")} {elementMD.TableName}";

            this.Invoke((MethodInvoker)delegate
            {
                lblDescription.Text = msj;
            });
            cntExistentes++;
            Global.WriteToFile(msj);
            sbCargaConteo();
        }
        private void HandleAddError(string element, string tipoElemento, dynamic elementMD, ref int cntErrores, ref int cntExistentes)
        {

            string nameElemento = element.Equals("UT") ? elementMD.TableName : element.Equals("UF") ? elementMD.Name : elementMD.Code;
            company.GetLastError(out int codigoErr, out string descripErr);
            if (codigoErr != -2035 && codigoErr != -5002)
            {
                cntErrores++;
                validados--;
                Global.WriteToFile($"{addon}: ERROR al instalar complemento - {tipoElemento} {nameElemento} - {codigoErr} - {descripErr}");
            }
            else
            {
                HandleAddExist(element, tipoElemento, elementMD, ref cntExistentes);
            }
            validados++;
            sbCargaConteo();
        }
        public void fn_createProcedures(string ps_addn)
        {
            try
            {
             
                SAPbobsCOM.Recordset lo_RevSetAux = null;
                string[] lo_ArrFiles = null;
                string ls_Qry = string.Empty;
                string ls_Tipo = string.Empty;
                string ls_TipoSQL = string.Empty;
                string ls_NmbFile = string.Empty;
                System.IO.StreamReader lo_StrmRdr = null;
                string ls_StrFile = string.Empty;
                string[] lo_ArrTpoScrpt = null;
                SAPbobsCOM.Recordset lo_RecSet = null;
                lo_RecSet = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);
                lo_RevSetAux = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);

                string carpeta = ps_addn;
                string ls_Path = System.Windows.Forms.Application.StartupPath + $"\\Resources\\{carpeta}";

                if (company.DbServerType == BoDataServerTypes.dst_HANADB)
                {
                    lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Scripts\HANA\", "*.sql");
                }
                else
                {
                    lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Scripts\SQL\", "*.sql");
                }

                for (int i = 0; i < lo_ArrFiles.GetUpperBound(0) + 1; i++)
                {

                    if (isRunning)
                    {
                        lo_StrmRdr = new System.IO.StreamReader(lo_ArrFiles[i]);
                        ls_StrFile = lo_StrmRdr.ReadToEnd();
                        lo_ArrTpoScrpt = ls_StrFile.Substring(0, 50).Split(new char[] { ' ' });
                        ls_NmbFile = System.IO.Path.GetFileName(lo_ArrFiles[i]);
                        ls_NmbFile = ls_NmbFile.Substring(0, ls_NmbFile.Length - 4);

                        if (lo_ArrTpoScrpt[1].Trim() == "PROCEDURE")
                        {
                            ls_Tipo = "el procedimiento ";
                            ls_TipoSQL = "= 'P'";
                        }
                        else if (lo_ArrTpoScrpt[1].Trim() == "VIEW")
                        {
                            ls_Tipo = "la vista ";
                            ls_TipoSQL = "= 'V'";
                        }
                        else if (lo_ArrTpoScrpt[1].Trim() == "FUNCTION")
                        {
                            ls_Tipo = "la funcion ";
                            ls_TipoSQL = "in (N'FN', N'IF', N'TF', N'FS', N'FT')";
                        }
                        if (company.DbServerType == BoDataServerTypes.dst_HANADB)
                        {
                            ls_Qry = @"SELECT COUNT('A') FROM ""SYS"".""OBJECTS"" WHERE ""OBJECT_NAME"" ='" + ls_NmbFile.Trim().ToUpper() + @"' AND ""SCHEMA_NAME"" = '" + company.CompanyDB + "'";
                        }
                        else
                        {
                            ls_Qry = @"SELECT COUNT(*) FROM sys.all_objects WHERE type " + ls_TipoSQL + " and name = '" + ls_NmbFile.Trim().ToUpper() + "'";
                        }

                        lo_RecSet.DoQuery(ls_Qry);
                        if (!lo_RecSet.EoF)
                        {
                            if (Convert.ToInt32(lo_RecSet.Fields.Item(0).Value) != 0)
                            {
                                try
                                {
                                    ls_Qry = @"DROP " + lo_ArrTpoScrpt[1].Trim() + " " + ls_NmbFile;
                                    lo_RecSet.DoQuery(ls_Qry);
                                    lo_RecSet.DoQuery(ls_StrFile);
                                    string mensaje = $"{ps_addn}: Se creo/actualizo {ls_Tipo} - {ls_NmbFile}";
                                    ActualizaDescripcion(mensaje);
                                    Global.WriteToFile(mensaje);
                                    validados++;
                                }
                                catch (Exception ex)
                                {
                                    validados--;
                                    string mensaje = $"{ps_addn}: ERROR al crear {ls_Tipo} - {ls_NmbFile} - {ex.Message}";
                                    ActualizaDescripcion(mensaje);
                                    Global.WriteToFile(mensaje);
                                }
                            }
                            else
                            {
                                try
                                {
                                    lo_RecSet.DoQuery(ls_StrFile);
                                    validados++;
                                    string mensaje = $"{ps_addn}: Se creo/actualizo {ls_Tipo} - {ls_NmbFile}";
                                    ActualizaDescripcion(mensaje);
                                    Global.WriteToFile(mensaje);
                                }
                                catch (Exception ex)
                                {
                                    validados--;
                                    string mensaje = $"{ps_addn}: ERROR al crear {ls_Tipo} - {ls_NmbFile} - {ex.Message}";
                                    ActualizaDescripcion(mensaje);
                                    Global.WriteToFile(mensaje);
                                }
                            }
                        }
                    }
                    sbCargaConteo();
                }

            }
            catch (Exception e)
            {
                string mensaje = $"{ps_addn}: ERROR al crear Scripts - {e.Message}";
                Global.WriteToFile(mensaje);
                ActualizaDescripcion(mensaje);
                MessageBox.Show(mensaje, "Scripts", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                ActualizaDescripcion("");
                //btnInstalador.Enabled = false;
            }
        }

        public void fn_createTransacs(string ps_addn)
        {
            try
            {
                SAPbobsCOM.Recordset lo_RecSet = null;
                SAPbobsCOM.Recordset lo_RevSetAux = null;
                string[] lo_ArrFiles = null;
                string ls_Qry = string.Empty;
                string ls_Tipo = string.Empty;
                string ls_TipoSQL = string.Empty;
                string ls_NmbFile = string.Empty;
                System.IO.StreamReader lo_StrmRdr = null;
                string ls_StrFile = string.Empty;
                string[] lo_ArrTpoScrpt = null;

                lo_RecSet = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);
                lo_RevSetAux = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);

                string carpeta = ps_addn;
                string ls_Path = System.Windows.Forms.Application.StartupPath + $"\\Resources\\{carpeta}";

                if (company.DbServerType == BoDataServerTypes.dst_HANADB)
                {
                    lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Transac\HANA\", "*.sql");
                }
                else
                {
                    lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Transac\SQL\", "*.sql");
                }

                Array.Sort(lo_ArrFiles);

                for (int i = 0; i < lo_ArrFiles.GetUpperBound(0) + 1; i++)
                {

                    if (isRunning)
                    {
                        lo_StrmRdr = new System.IO.StreamReader(lo_ArrFiles[i]);
                        ls_StrFile = lo_StrmRdr.ReadToEnd();
                        lo_ArrTpoScrpt = ls_StrFile.Substring(0, 50).Split(new char[] { ' ' });
                        ls_NmbFile = System.IO.Path.GetFileName(lo_ArrFiles[i]);
                        ls_NmbFile = ls_NmbFile.Substring(0, ls_NmbFile.Length - 4);

                        if (lo_ArrTpoScrpt[1].Trim() == "PROCEDURE")
                        {
                            ls_Tipo = "el procedimiento ";
                            ls_TipoSQL = "= 'P'";
                        }
                        else if (lo_ArrTpoScrpt[1].Trim() == "VIEW")
                        {
                            ls_Tipo = "la vista ";
                            ls_TipoSQL = "= 'V'";
                        }
                        else if (lo_ArrTpoScrpt[1].Trim() == "FUNCTION")
                        {
                            ls_Tipo = "la funcion ";
                            ls_TipoSQL = "in (N'FN', N'IF', N'TF', N'FS', N'FT')";
                        }
                        if (company.DbServerType == BoDataServerTypes.dst_HANADB)
                        {
                            ls_Qry = @"SELECT COUNT('A') FROM ""SYS"".""OBJECTS"" WHERE ""OBJECT_NAME"" ='" + ls_NmbFile.Split('.')[1].Trim().ToUpper() + @"' AND ""SCHEMA_NAME"" = '" + company.CompanyDB + "'";
                        }
                        else
                        {
                            ls_Qry = @"SELECT COUNT(*) FROM sys.all_objects WHERE type " + ls_TipoSQL + " and name = '" + ls_NmbFile.Trim().ToUpper() + "'";
                        }

                        lo_RecSet.DoQuery(ls_Qry);
                        if (!lo_RecSet.EoF)
                        {
                            if (Convert.ToInt32(lo_RecSet.Fields.Item(0).Value) != 0)
                            {
                                try
                                {
                                   // ls_Qry = @"DROP " + lo_ArrTpoScrpt[1].Trim() + " " + ls_NmbFile;
                                   // lo_RecSet.DoQuery(ls_Qry);
                                    //lo_RecSet.DoQuery(ls_StrFile);
                                    string mensaje = $"{ps_addn}: Se creo/actualizo {ls_Tipo} - {ls_NmbFile}";
                                    ActualizaDescripcion(mensaje);
                                    Global.WriteToFile(mensaje);
                                    validados++;
                                }
                                catch (Exception ex)
                                {
                                    validados--;
                                    string mensaje = $"{ps_addn}: ERROR al crear {ls_Tipo} - {ls_NmbFile} - {ex.Message}";
                                    ActualizaDescripcion(mensaje);
                                    Global.WriteToFile(mensaje);
                                }
                            }
                            else
                            {
                                try
                                {
                                    lo_RecSet.DoQuery(ls_StrFile);
                                    validados++;
                                    string mensaje = $"{ps_addn}: Se creo/actualizo {ls_Tipo} - {ls_NmbFile}";
                                    ActualizaDescripcion(mensaje);
                                    Global.WriteToFile(mensaje);
                                }
                                catch (Exception ex)
                                {
                                    validados--;
                                    string mensaje = $"{ps_addn}: ERROR al crear {ls_Tipo} - {ls_NmbFile} - {ex.Message}";
                                    ActualizaDescripcion(mensaje);
                                    Global.WriteToFile(mensaje);
                                }
                            }
                        }
                    }
                    sbCargaConteo();
                }

            }
            catch (Exception e)
            {
                string mensaje = $"{ps_addn}: ERROR al crear Scripts - {e.Message}";
                Global.WriteToFile(mensaje);
                ActualizaDescripcion(mensaje);
                MessageBox.Show(mensaje, "Scripts", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                ActualizaDescripcion("");
                //btnInstalador.Enabled = false;
            }
        }

        private void ActualizaDescripcion(string mensaje)
        {
            this.Invoke((MethodInvoker)delegate
            {
                lblDescription.Text = mensaje;
            });
        }

        public void fn_inicializacion(string addon)
        {
            SAPbobsCOM.Recordset recordset = company.GetBusinessObject(BoObjectTypes.BoRecordset);

            if (addon == "Letras")
            {
                string path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\Letras\\DataDefecto.xlsm";

                // Obtiene EXCEL DATA
                ms.Application excelApp = new ms.Application();
                Workbook workbook = excelApp.Workbooks.Open(path);

                foreach (Worksheet worksheet in workbook.Sheets)
                {
                    string tablaSAP = worksheet.Name; // TABLA A INSERTAR LA DATA
                    if (!string.IsNullOrEmpty(tablaSAP) && tablaSAP != "Listas")
                    {
                        Microsoft.Office.Interop.Excel.Range usedRange = worksheet.UsedRange;

                        for (int row = 3; row < usedRange.Rows.Count; row++)
                        {
                            try
                            {
                                // Tiene que iniciar aqui
                                SAPbobsCOM.UserTable userTable = null;
                                userTable = company.UserTables.Item(tablaSAP);
                                userTable.Code = $"{usedRange.Cells[row, 1].Value2}";
                                userTable.Name = $"{usedRange.Cells[row, 2].Value2}";

                                for (int col = 3; col <= usedRange.Columns.Count; col++)
                                {
                                    if (usedRange.Cells[1, col].Value2 != "Resultados")
                                    {
                                        string campoSAP = usedRange.Cells[1, col].Value2;  // CAMPOS SAP
                                        var valor = (usedRange.Cells[row, col] as Microsoft.Office.Interop.Excel.Range).Value2;

                                        userTable.UserFields.Fields.Item(campoSAP).Value = $"{valor}";
                                    }
                                }
                                userTable.Add();

                                System.Runtime.InteropServices.Marshal.ReleaseComObject(userTable);
                                userTable = null;
                            }
                            catch (Exception)
                            {

                                // throw;
                            }
                        }
                    }
                }
            }
            else if (addon == "Localizacion")
            {
               // fn_iniciaTransacPorDefecto();
                // select :error, :error_message FROM dummy;
                string path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{"Localizacion"}\\DataDefecto6.xlsm";

                // Obtiene EXCEL DATA
                ms.Application excelApp = new ms.Application();
                Workbook workbook = excelApp.Workbooks.Open(path);

                foreach (Worksheet worksheet in workbook.Sheets)
                {
                    string tablaSAP = worksheet.Name; // TABLA A INSERTAR LA DATA
                    if (!string.IsNullOrEmpty(tablaSAP) && tablaSAP != "Listas")
                    {
                        Microsoft.Office.Interop.Excel.Range usedRange = worksheet.UsedRange;

                        for (int row = 3; row < usedRange.Rows.Count; row++)
                        {
                            try
                            {
                                // Tiene que iniciar aqui
                                SAPbobsCOM.UserTable userTable = null;
                                userTable = company.UserTables.Item(tablaSAP);
                                userTable.Code = $"{usedRange.Cells[row, 1].Value2}";
                                userTable.Name = $"{usedRange.Cells[row, 2].Value2}";

                                for (int col = 3; col <= usedRange.Columns.Count; col++)
                                {
                                    if (usedRange.Cells[1, col].Value2 != "Resultados")
                                    {
                                        string campoSAP = usedRange.Cells[1, col].Value2;  // CAMPOS SAP
                                        var valor = (usedRange.Cells[row, col] as Microsoft.Office.Interop.Excel.Range).Value2;

                                        userTable.UserFields.Fields.Item(campoSAP).Value = $"{valor}";
                                    }
                                }
                                userTable.Add();

                                System.Runtime.InteropServices.Marshal.ReleaseComObject(userTable);
                                userTable = null;
                            }
                            catch (Exception)
                            {

                               // throw;
                            }
                        }
                    } 
                }
            }
            else if (addon == "CCHHE")
            {

                SAPbobsCOM.Recordset lo_RecSet = null;
                string ls_Qry = string.Empty;
                SAPbobsCOM.UserTablesMD lo_UsrTblMD = null;
                SAPbobsCOM.UserTable lo_UsrTbl = null;

                lo_RecSet = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);
                lo_UsrTblMD = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oUserTables);
                if (lo_UsrTblMD.GetByKey("STR_CCHEAR_SYS"))
                {
                    lo_UsrTbl = company.UserTables.Item("STR_CCHEAR_SYS");
                    ls_Qry = @"SELECT ""U_CE_ID"" FROM ""@STR_CCHEAR_SYS""";
                    lo_RecSet.DoQuery(ls_Qry);
                    if (lo_RecSet.EoF)
                    {
                        lo_UsrTbl.Code = "001";
                        lo_UsrTbl.Name = "001";
                        lo_UsrTbl.UserFields.Fields.Item("U_CE_ID").Value = "1";
                        lo_UsrTbl.Add();

                    }

                }

            }
            else if (addon == "SIRE")
            {
                string path = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\Sire\\DataDefecto.xlsm";

                // Obtiene EXCEL DATA
                ms.Application excelApp = new ms.Application();
                Workbook workbook = excelApp.Workbooks.Open(path);

                foreach (Worksheet worksheet in workbook.Sheets)
                {
                    string tablaSAP = worksheet.Name; // TABLA A INSERTAR LA DATA
                    if (!string.IsNullOrEmpty(tablaSAP) && tablaSAP != "Listas")
                    {
                        Microsoft.Office.Interop.Excel.Range usedRange = worksheet.UsedRange;

                        for (int row = 3; row < usedRange.Rows.Count; row++)
                        {
                            try
                            {
                                // Tiene que iniciar aqui
                                SAPbobsCOM.UserTable userTable = null;
                                userTable = company.UserTables.Item(tablaSAP);
                                userTable.Code = $"{usedRange.Cells[row, 1].Value2}";
                                userTable.Name = $"{usedRange.Cells[row, 2].Value2}";

                                for (int col = 3; col <= usedRange.Columns.Count; col++)
                                {
                                    if (usedRange.Cells[1, col].Value2 != "Resultados")
                                    {
                                        string campoSAP = usedRange.Cells[1, col].Value2;  // CAMPOS SAP

                                        if (!string.IsNullOrEmpty(campoSAP))
                                        {
                                            var valor = (usedRange.Cells[row, col] as Microsoft.Office.Interop.Excel.Range).Value2;

                                            userTable.UserFields.Fields.Item(campoSAP).Value = $"{valor}";
                                        }
                                    }
                                }
                                userTable.Add();

                                System.Runtime.InteropServices.Marshal.ReleaseComObject(userTable);
                                userTable = null;
                            }
                            catch (Exception)
                            {

                                // throw;
                            }
                        }
                    }
                }
            }
            MessageBox.Show("Se terminó con la inicialización de la configuración", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
            Global.WriteToFile($"{addon}: Se termino con la inicialización de la configuración");

        }

        public void fn_iniciaTransacPorDefecto()
        {
            SAPbobsCOM.Recordset recordset = company.GetBusinessObject(BoObjectTypes.BoRecordset);
            try
            {
                // Valida si el procedimiento ya está creado 
                /*if (fn_validaProcedimientoCreado("STR_TN_GENERAL"))
                {
                    // Inserta los necesarios y luego actualiza - SOLO HANA      
                    string posicionTransac = ConfigurationManager.AppSettings["indexProcedimientoHana"].ToString();
                    // Hacer Operaciones Obtener el procedimiento                                                                           // SBO_SP_TRANSACTIONNOTIFICATION
                    string qry = $"SELECT \"DEFINITION\" FROM SYS.PROCEDURES where \"SCHEMA_NAME\" = '{company.CompanyDB}' AND \"PROCEDURE_NAME\" = 'SBO_SP_TRANSACTIONNOTIFICATION'";
                    recordset.DoQuery(qry);
                    string procPlano = "";

                    if (recordset.Fields.Count > 0)
                    {
                        procPlano = recordset.Fields.Item(0).Value.ToString();
                    }
                    int posNuevoTrnsc = procPlano.LastIndexOf(posicionTransac); // 774

                    if (posNuevoTrnsc != -1)
                    {
                        string newContent = "IF :error=0 \r\nTHEN\r\n\tCALL STR_TN_General(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error, :error_message);\r\nEND IF;\n\n";
                        procPlano = procPlano.Insert(posNuevoTrnsc, newContent);
                    }
                    // Actualiza el TRANSAC 
                    procPlano = procPlano.Replace("CREATE PROCEDURE", "ALTER PROCEDURE");

                    recordset.DoQuery(procPlano);
                }
                else {*/
                    fn_createTransacs("Localizacion");

                    // Inserta los necesarios y luego actualiza - SOLO HANA      
                    string posicionTransac = ConfigurationManager.AppSettings["indexProcedimientoHana"].ToString();
                    // Hacer Operaciones Obtener el procedimiento                                                                           // SBO_SP_TRANSACTIONNOTIFICATION
                    string qry = $"SELECT \"DEFINITION\" FROM SYS.PROCEDURES where \"SCHEMA_NAME\" = '{company.CompanyDB}' AND \"PROCEDURE_NAME\" = 'SBO_SP_TRANSACTIONNOTIFICATION'";
                    recordset.DoQuery(qry);
                    string procPlano = "";

                    if (recordset.Fields.Count > 0)
                    {
                        procPlano = recordset.Fields.Item(0).Value.ToString();
                    }
                    int posNuevoTrnsc = procPlano.LastIndexOf(posicionTransac); // 774

                    if (posNuevoTrnsc != -1)
                    {
                        string newContent = "IF :error=0 \r\nTHEN\r\n\tCALL STR_TN_General(:object_type,:transaction_type,:list_of_cols_val_tab_del,:error, :error_message);\r\nEND IF;\n\n";
                        procPlano = procPlano.Insert(posNuevoTrnsc, newContent);
                    }
                    // Actualiza el TRANSAC 
                    procPlano = procPlano.Replace("CREATE PROCEDURE", "ALTER PROCEDURE");

                    recordset.DoQuery(procPlano);
               // }             
            }
            catch (Exception)
            {
                throw;
            }
            finally {
                recordset = null;
            }
        }
        private void materialButton9_Click(object sender, EventArgs e)
        {
            abrirTxt();

        }
        public bool fn_validaProcedimientoCreado(string procedimiento)
        {
            SAPbobsCOM.Recordset recordset = company.GetBusinessObject(BoObjectTypes.BoRecordset);
            try
            {
               
                string qry = $"SELECT \"DEFINITION\" FROM SYS.PROCEDURES where \"SCHEMA_NAME\" = 'SBO_CRL_210922' AND \"PROCEDURE_NAME\" = '{procedimiento}'";
                recordset.DoQuery(qry);

                return !string.IsNullOrEmpty(recordset.Fields.Item(0).Value);
            }
            finally
            {
                recordset = null;
            }
        }
        public void abrirTxt()
        {
            string filepath = $"{System.Windows.Forms.Application.StartupPath}\\Logs\\Service_Creation_Log_{DateTime.Now.Date.ToShortDateString().Replace('/', '_')}.txt";

            try
            {
                Process.Start("notepad.exe", filepath);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error al abrir el archivo: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void materialButton4_Click(object sender, EventArgs e)
        {
            abrirTxt();

        }

        private void materialButton6_Click(object sender, EventArgs e)
        {
            abrirTxt();
        }

        private void materialButton8_Click(object sender, EventArgs e)
        {
            abrirTxt();

        }

        private void FrmInstalador_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Iterar sobre todos los formularios abiertos en la aplicación
            foreach (System.Windows.Forms.Form formulario in System.Windows.Forms.Application.OpenForms)
            {
                // Cerrar cada formulario (excepto el formulario principal, si es necesario)
                if (formulario != this) // Puedes ajustar esta condición según tus necesidades
                {
                    formulario.Close();
                }
            }
        }

        private void tabPage4_Click(object sender, EventArgs e)
        {

        }

        private void materialLabel8_Click(object sender, EventArgs e)
        {
            AbrirInstalacion();
        }

        private void AbrirInstalacion()
        {
            string SLDServer = company.SLDServer;
            string protocol = "https";
            string controll = "ExtensionManager";

            string link = $"{protocol}://{SLDServer}/{controll}";

            Process.Start(link);
        }

        private void materialLabel6_Click(object sender, EventArgs e)
        {
            AbrirInstalacion();
        }

        private void materialLabel9_Click(object sender, EventArgs e)
        {
            AbrirInstalacion();
        }

        private void materialLabel10_Click(object sender, EventArgs e)
        {
            AbrirInstalacion();
        }

        private void materialButton13_Click(object sender, EventArgs e)
        {
            MessageBox.Show($"Error al abrir el archivo: No se encuentra", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        private void materialButton15_Click(object sender, EventArgs e)
        {
            MessageBox.Show($"Error al abrir el archivo: No se encuentra", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        private void materialButton11_Click_2(object sender, EventArgs e)
        {
            MessageBox.Show($"Error al abrir el archivo: No se encuentra", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        private void materialButton2_Click(object sender, EventArgs e)
        {
            MessageBox.Show($"Error al abrir el archivo: No se encuentra", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            AbrirInstalacion();
        }

        private void linkLabel3_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            AbrirInstalacion();
        }

        private void linkLabel2_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            AbrirInstalacion();
        }

        private void linkLabel4_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            AbrirInstalacion();
        }
    }
}
