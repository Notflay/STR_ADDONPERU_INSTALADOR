using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Windows.Forms;
using MaterialSkin.Controls;
using SAPbobsCOM;
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
        private SAPbobsCOM.Company companyRS;
        private string addon;
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
            companyRS = company;
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
            setControlTab();
            materialTabControl1.SelectedIndex = 0;
            instalaComplementos("Localizacion");

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
            int porcentaje = promedioPorcentaje();
            lblInstalador.Text = $"Descarga ({porcentaje}%)";

            // Establecer el valor absoluto en lugar de incrementar
            progressBar.Value = porcentaje;
        }

        public int promedioPorcentaje()
        {
            double valor = ((double)validados / totales) * 100;
            int valorFinal = (int)Math.Round(valor);

            // Asegúrate de que el valor esté dentro del rango de la barra de progreso
            valorFinal = Math.Min(Math.Max(valorFinal, progressBar.Minimum), progressBar.Maximum);

            return valorFinal;
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

        public bool tableExis(string tabla)
        {
            SAPbobsCOM.Recordset rs = companyRS.GetBusinessObject(BoObjectTypes.BoRecordset);
            try
            {
                rs.DoQuery($"SELECT TOP 1 * FROM \"@{tabla}\"");

                rs = null;
                return true;
            }
            catch (Exception)
            {
                rs = null;
                return false;
            }
        }

        public bool columnExis(string campo, string tabla)
        {
            SAPbobsCOM.Recordset rs = companyRS.GetBusinessObject(BoObjectTypes.BoRecordset);

            try
            {

                rs.DoQuery($"SELECT TOP 1 \"U_{campo}\" FROM \"{tabla}\"");

                rs = null;
                return true;
            }
            catch (Exception)
            {
                rs = null;
                return false;
            }
        }

        public void instalaComplementos(string addon)
        {
            CreateElements(addon);

            if (MessageBox.Show("¿Deseas continuar con la creación de procedimientos?", "Scripts", MessageBoxButtons.YesNo, MessageBoxIcon.Information) == DialogResult.Yes)
            {
                fn_createProcedures(addon);

                if (addon == "Letras" | addon == "CCHHE" | addon == "SIRE")
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
        }

        private void CreateElements(string addon)
        {
            this.addon = addon;
            SAPbobsCOM.Company companyAux = null;
            SAPbobsCOM.Company companyAux2 = null;
            string pathFile = string.Empty;
            int cntErrores = 0;
            int cntExistentes = 0;

            try
            {
                companyAux = this.company;
                string[] elements = { "UT", "UF", "UO" };
                GC.Collect();
                GC.WaitForPendingFinalizers();

                foreach (var elementType in elements)
                {
                    Cursor.Current = Cursors.WaitCursor;
                    pathFile = $"{System.Windows.Forms.Application.StartupPath}\\Resources\\{addon}\\{elementType}.vte";

                    if (!File.Exists(pathFile))
                        throw new FileNotFoundException();

                    ProcessElementsOfType(elementType, pathFile, ref cntErrores, ref cntExistentes);
                }
            }
            catch (Exception ex)
            {
                // Manejo de excepciones general
                MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                DisplayFinalMessage(cntErrores, cntExistentes);
                lblDescription.Text = "";
            }
        }

        private void ValidExisElements(string elementType, string pathFile, ref List<int> ints, ref int cntExistentes)
        {
            SAPbobsCOM.Company companyAux = company;
            try
            {

                int cntElementos = companyAux.GetXMLelementCount(pathFile);
                for (int i = 0; i < cntElementos; i++)
                {
                    dynamic elemntMD = companyAux.GetBusinessObjectFromXML(pathFile, i);

                    bool exists = elementType == "UT" ? tableExis(elemntMD.TableName) : elementType == "UF" ? columnExis(elemntMD.Name, elemntMD.TableName) : false;

                    if (!exists)
                        ints.Add(i);
                    else
                    {
                        string message = $"{addon}: Elemento en SAP complemento {(elementType == "UF" ? elemntMD.Name + "de la tabla " + elemntMD.TableName : elemntMD.TableName)} ya existente";
                        lblDescription.Text = message;
                        cntExistentes++;
                        Global.WriteToFile(message);
                        validados++;
                        sbCargaConteo();
                        CleanUpObjects(elemntMD);
                    }
                }
            }
            catch (Exception e)
            {

                Global.WriteToFile(e.Message);
            }
            finally
            {

                companyAux = null;
            }
        }

        private void ProcessElementsOfType(string elementType, string pathFile, ref int cntErrores, ref int cntExistentes)
        {
            List<int> invalidados = new List<int>();
            SAPbobsCOM.Company companyAux = this.company;

            ValidExisElements(elementType, pathFile, ref invalidados, ref cntExistentes);

            for (int i = 0; i < invalidados.Count; i++)
            {
                dynamic elementMD = null;

                try
                {
                    elementMD = companyAux.GetBusinessObjectFromXML(pathFile, invalidados[i]);
                    string message = $"Creando {GetElementTypeDescription(elementType)} {(elementType.Equals("UT") || elementType.Equals("UO") ? "" : $"{elementMD.Name} de la tabla: ")} {elementMD.TableName}";
                    lblDescription.Text = message;

                    string nameElement = elementType == "UT" ? elementMD.TableName : elementType == "UF" ? elementMD.Name : elementMD.Code;
                    ProcessNewElement(elementType, elementMD, pathFile, ref cntErrores, ref cntExistentes, i);

                }
                catch (Exception ex)
                {
                    // Manejo de excepciones específico para este proceso
                    Global.WriteToFile($"{addon}: ERROR al instalar complementos " + ex.Message);
                }
                finally
                {
                    CleanUpObjects(ref elementMD);
                }
            }
        }
        private void HandleExistingElement(string elementType, dynamic elementMD, dynamic elementMD2, ref int cntExistentes)
        {
            string message = $"{addon}: Ya existe en SAP complemento {GetElementTypeDescription(elementType)} {GetNameElement(elementType, elementMD, elementMD2)}";
            lblDescription.Text = message;
            cntExistentes++;
            Global.WriteToFile(message);
            validados++;
            sbCargaConteo();
        }

        private void ProcessNewElement(string elementType, dynamic elementMD, string pathFile, ref int cntErrores, ref int cntExistentes, int num)
        {
            try
            {
                dynamic elementMD2 = null;
                SAPbobsCOM.Company companyAux2 = this.company;
                elementMD2 = companyAux2.GetBusinessObjectFromXML(pathFile, num);

                //CleanUpObjects(ref elementMD2);
                //Thread.Sleep(2000);
                if (elementMD2.Add() != 0)
                {
                    HandleAddError(elementType, elementMD, elementMD2, ref cntErrores, ref cntExistentes);
                }
                else
                {
                    HandleAddSuccess(elementType, elementMD2);
                }
            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                // CleanUpObjects(ref elementMD2);
            }
        }
        private void CleanUpObjects(ref dynamic obj)
        {
            try
            {
                System.Runtime.InteropServices.Marshal.ReleaseComObject(obj);
            }
            catch (Exception)
            {
            }
            finally
            {
                obj = null;
            }
        }
        private void HandleAddError(string elementType, dynamic elementMD, dynamic elementMD2, ref int cntErrores, ref int cntExistentes)
        {
            SAPbobsCOM.Company companyAux = this.company;
            companyAux.GetLastError(out int errorCode, out string errorDescription);

            if (errorCode != -2035 && errorCode != -5002)
            {
                cntErrores++;
                validados--;
                Global.WriteToFile($"{addon}: ERROR al instalar complemento - {GetElementTypeDescription(elementType)} {GetNameElement(elementType, elementMD, elementMD2)} - {errorCode} - {errorDescription}");
            }
            else
            {
                string message = $"{addon}: Ya existe en SAP complemento {GetElementTypeDescription(elementType)} {GetNameElement(elementType, elementMD, elementMD2)}";
                lblDescription.Text = message;
                cntExistentes++;
                Global.WriteToFile(message);
            }
        }

        private void HandleAddSuccess(string elementType, dynamic elementMD)
        {
            string message = $"{addon}: Se creó en SAP complemento {GetElementTypeDescription(elementType)} {GetNameElement(elementType, elementMD)}";
            lblDescription.Text = message;
            Global.WriteToFile(message);
            validados++;
            sbCargaConteo();
        }

        private string GetElementTypeDescription(string elementType)
        {
            return elementType.Equals("UT") ? "Tabla" : elementType.Equals("UF") ? "Campo" : "Objeto";
        }

        private string GetNameElement(string elementType, dynamic elementMD, dynamic elementMD2 = null)
        {
            if (elementType == "UT")
            {
                return elementMD2 != null ? elementMD2.TableName : elementMD.TableName;
            }
            else if (elementType == "UF")
            {
                return elementMD2 != null ? elementMD2.Name : elementMD.Name;
            }
            else
            {
                return elementMD2 != null ? elementMD2.Code : elementMD.Code;
            }
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

        public void fn_createProcedures(string ps_addn)
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
                    lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Scripts\HANA\", "*.sql");
                }
                else
                {
                    lo_ArrFiles = System.IO.Directory.GetFiles(ls_Path + @"\Scripts\SQL\", "*.sql");
                }

                for (int i = 0; i < lo_ArrFiles.GetUpperBound(0) + 1; i++)
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
                                lblDescription.Text = mensaje;
                                Global.WriteToFile(mensaje);
                                validados++;
                            }
                            catch (Exception ex)
                            {
                                validados--;
                                string mensaje = $"{ps_addn}: ERROR al crear {ls_Tipo} - {ls_NmbFile} - {ex.Message}";
                                lblDescription.Text = mensaje;
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
                                lblDescription.Text = mensaje;
                                Global.WriteToFile(mensaje);
                            }
                            catch (Exception ex)
                            {
                                validados--;
                                string mensaje = $"{ps_addn}: ERROR al crear {ls_Tipo} - {ls_NmbFile} - {ex.Message}";
                                lblDescription.Text = mensaje;
                                Global.WriteToFile(mensaje);
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
                lblDescription.Text = mensaje;
                MessageBox.Show(mensaje, "Scripts", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                lblDescription.Text = "";
                btnInstalador.Enabled = false;
            }
        }

        public void fn_inicializacion(string addon)
        {

            SAPbobsCOM.Recordset recordset = company.GetBusinessObject(BoObjectTypes.BoRecordset);

            if (addon == "Letras")
            {
                if (company.DbServerType == BoDataServerTypes.dst_HANADB)
                {
                    recordset.DoQuery("CALL STR_SP_LTR_InicializarConfiguracion");

                    recordset.DoQuery("CALL STR_SP_LTR_InsercionConfCuentas");
                }
                else
                {
                    recordset.DoQuery("EXEC STR_SP_LTR_InicializarConfiguracion");

                    recordset.DoQuery("EXEC STR_SP_LTR_InsercionConfCuentas");
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
                if (company.DbServerType == BoDataServerTypes.dst_HANADB)
                    recordset.DoQuery("CALL STR_SIRE_InicializarConfiguracion");
                else
                    recordset.DoQuery("EXEC STR_SIRE_InicializarConfiguracion");
            }
            MessageBox.Show("Se terminó con la inicialización de la configuración", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
            Global.WriteToFile($"{addon}: Se termino con la inicialización de la configuración");

        }
        private void btnInstSire_Click(object sender, EventArgs e)
        {
            setControlTab();
            materialTabControl1.SelectedIndex = 1;
            instalaComplementos("SIRE");
        }

        private void btnInstEar_Click(object sender, EventArgs e)
        {
            setControlTab();
            materialTabControl1.SelectedIndex = 2;
            instalaComplementos("CCHHE");
        }

        private void btnInstLetra_Click(object sender, EventArgs e)
        {
            setControlTab();
            materialTabControl1.SelectedIndex = 3;
            instalaComplementos("Letras");
        }

        private void materialButton9_Click(object sender, EventArgs e)
        {
            abrirTxt();

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
    }
}
