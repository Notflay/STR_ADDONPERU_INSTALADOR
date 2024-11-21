using System;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Reflection.Emit;
using System.Security.Cryptography;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml.Linq;
using MaterialSkin.Controls;
using Microsoft.Office.Interop.Excel;
using SAPbobsCOM;
using STR_ADDONPERU_INSTALADOR.Entidad;
using STR_ADDONPERU_INSTALADOR.Util;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.Rebar;
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

        public bool columnExis(string campo, string tabla, string element, dynamic elementMD, ref int cntExistentes, bool valorValidoEnSap, ref bool update)
        {
            SAPbobsCOM.Recordset rs = (SAPbobsCOM.Recordset)company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);

            try
            {
                string query = $"SELECT CASE WHEN COUNT(T1.\"FieldID\") > 0 THEN 1 ELSE 0 END AS \"ExisteCol\", " +
                               $"CASE WHEN COUNT(T0.\"FieldID\") > 0 THEN 1 ELSE 0 END AS \"ExisteValidos\" " +
                               $"FROM CUFD T1 LEFT JOIN UFD1 T0 ON T0.\"FieldID\" = T1.\"FieldID\" AND T0.\"TableID\" = T1.\"TableID\" " +
                               $"WHERE T1.\"AliasID\" = '{campo}' AND T1.\"TableID\" = '{tabla}' " +
                               $"GROUP BY T1.\"FieldID\", T0.\"FieldID\"";

                rs.DoQuery(query);

                bool existeCol = rs.Fields.Item("ExisteCol").Value == 1;
                bool existeValidos = rs.Fields.Item("ExisteValidos").Value == 1;

                if (existeCol)
                {
                    string tipoElement = GetElementTypeDescription(element);
                    validados++;
                    HandleAddExist(element, tipoElement, elementMD, ref cntExistentes);
                    if (valorValidoEnSap != existeValidos) // Asigna el valor de `existeValidos` a `update` para usarlo fuera de la función
                    {
                        update = true;
                        return false;
                    }
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                Global.WriteToFile($"{addon}: ERROR al verificar columna " + ex.Message);
                return false;
            }
            finally
            {
                if (rs != null)
                {
                    System.Runtime.InteropServices.Marshal.ReleaseComObject(rs);
                    rs = null;
                }
                GC.Collect();
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
                                try
                                {
                                    lo_StrmRdr = new System.IO.StreamReader(lo_ArrFiles[i]);
                                    ls_StrFile = lo_StrmRdr.ReadToEnd();


                                    lo_RecSet.DoQuery(ls_StrFile);
                                }
                                catch (Exception ex)
                                {
                                    Global.WriteToFile($"instalaComplementos - {ex.Message}");
                                }
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
            catch (Exception ex)
            {
                Global.WriteToFile($"instalaComplementos - {ex.Message}");
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
            List<Dictionary<string, object>> elemtsProcesar = new List<Dictionary<string, object>>();

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

        private void InsertElementosProcess(string pathFile, string e, ref List<Dictionary<string, object>> elemtsProcesar, string element, ref int cntExistentes)
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
                            // elemtsProcesar["index"]
                            // elemtsProcesar["update"]
                            bool update = false;
                            elemtoMD = companyAux.GetBusinessObjectFromXML(pathFile, i);
                            bool exis = e == "UT" ? tableExis(elemtoMD.TableName, element, elemtoMD, ref cntExistentes) : e == "UF" ?
                                columnExis(elemtoMD.Name, elemtoMD.TableName, element, elemtoMD, ref cntExistentes, elemtoMD.ValidValues.Count > 1, ref update) : false;
                            if (!exis)
                            {
                                var keyValuePairs = new Dictionary<string, object>
                                {
                                    { "index", i },
                                    { "update", update } // Asumiendo que se trata de un nuevo elemento por defecto
                                };
                                elemtsProcesar.Add(keyValuePairs);
                            }
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
        private void ProcessElementsOfType(string pathFile, string element, ref int cntErrores, ref int cntExistentes, ref List<Dictionary<string, object>> elemtsProcesar)
        {
            SAPbobsCOM.Company companyAux = this.company;
            try
            {
                foreach (var elemInfo in elemtsProcesar)
                {
                    int elementIndex = (int)elemInfo["index"];
                    bool update = (bool)elemInfo["update"];
                    dynamic elementoMD = null;
                    dynamic existingField = null;

                    SAPbobsCOM.ValidValues validValue = null;

                    try
                    {
                        string tipoElemento = GetElementTypeDescription(element);
                        elementoMD = companyAux.GetBusinessObjectFromXML(pathFile, elementIndex);
                        string mensaje = $"Creando {tipoElemento.Replace('s', ' ')} {(element.Equals("UT") | element.Equals("UO") ? "" : $"{elementoMD.Name} de la tabla: ")} {elementoMD.TableName}";

                        if (update)
                        {
                            existingField = GetCurrentFieldData(elementoMD.TableName, elementoMD.Name);

                            // Eliminar los valores existentes si es necesario
                            for (int i = existingField.ValidValues.Count - 1; i >= 0; i--)
                            {
                                existingField.ValidValues.SetCurrentLine(i);
                                existingField.ValidValues.Delete();
                            }

                            // Agregar nuevos ValidValues
                            for (int i = 0; i < elementoMD.ValidValues.Count; i++)
                            {
                                elementoMD.ValidValues.SetCurrentLine(i);

                                existingField.ValidValues.Value = elementoMD.ValidValues.Value;
                                existingField.ValidValues.Description = elementoMD.ValidValues.Description;
                                existingField.ValidValues.Add();
                            }

                            if (!string.IsNullOrEmpty(elementoMD.DefaultValue)) existingField.DefaultValue = elementoMD.DefaultValue;

                            UpdateElement(existingField, element, tipoElemento, ref cntErrores, ref cntExistentes);
                        }
                        else
                        {
                            ProcessNewElement(elementoMD, element, tipoElemento, ref cntErrores, ref cntExistentes);
                        }
                    }
                    catch (Exception ex)
                    {
                        Global.WriteToFile($"{addon}: ERROR al instalar complementos " + ex.Message);
                    }
                    finally
                    {

                        //if (elementoMD != null)
                        //{
                        //    System.Runtime.InteropServices.Marshal.ReleaseComObject(elementoMD);
                        //    elementoMD = null;
                        //}

                        if (validValue != null)
                        {
                            System.Runtime.InteropServices.Marshal.ReleaseComObject(validValue);
                            validValue = null;
                        }
                    }
                }
            }
            catch { }
            finally
            {
                elemtsProcesar.Clear();
            }
        }

        private dynamic GetCurrentFieldData(string tableName, string fieldName)
        {
            SAPbobsCOM.UserFieldsMD userField = null;
            SAPbobsCOM.Recordset rs = (SAPbobsCOM.Recordset)company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);

            try
            {
                // Consulta para obtener el FieldID y TableID actuales
                string query = $"SELECT \"FieldID\", \"TableID\" FROM \"CUFD\" WHERE \"TableID\" = '{tableName}' AND \"AliasID\" = '{fieldName}'";
                rs.DoQuery(query);

                if (rs.RecordCount > 0)
                {
                    int fieldID = rs.Fields.Item("FieldID").Value;
                    string tableID = rs.Fields.Item("TableID").Value.ToString();

                    // Obtiene el objeto UserFieldsMD para el campo
                    userField = (SAPbobsCOM.UserFieldsMD)company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oUserFields);
                    if (userField.GetByKey(tableID, fieldID))
                    {
                        return userField; // Devuelve el objeto UserFieldsMD existente
                    }
                }

                return null; // No se encontró el campo
            }
            catch (Exception ex)
            {
                Global.WriteToFile($"{addon}: ERROR al obtener datos del campo " + ex.Message);
                return null;
            }
            finally
            {
                //if (userField != null)
                //{
                //    System.Runtime.InteropServices.Marshal.ReleaseComObject(userField);
                //    userField = null;
                //}
                if (rs != null)
                {
                    System.Runtime.InteropServices.Marshal.ReleaseComObject(rs);
                    rs = null;
                }
                // GC.Collect();
            }
        }

        //private void ProcessElementsOfType(string pathFile, string element, ref int cntErrores, ref int cntExistentes, ref List<Dictionary<string, object>> elemtsProcesar)
        //{
        //    SAPbobsCOM.Company companyAux = null;
        //    int cntElementos = 0;
        //    companyAux = this.company;

        //    try
        //    {
        //        //cntElementos = company.GetXMLelementCount(pathFile);
        //        //for (int i = 0; i < cntElementos; i++)
        //        for (int i = 0; i < elemtsProcesar.Count; i++)
        //        {
        //            dynamic elementoMD = null;
        //            try
        //            {
        //                string tipoElemento = GetElementTypeDescription(element);
        //                //elementoMD = companyAux.GetBusinessObjectFromXML(pathFile, i);
        //                elementoMD = companyAux.GetBusinessObjectFromXML(pathFile, elemtsProcesar[i]);
        //                string mensaje = $"Creando {tipoElemento.Replace('s', ' ')} {(element.Equals("UT") | element.Equals("UO") ? "" : $"{elementoMD.Name} de la tabla: ")} {elementoMD.TableName}";
        //                this.Invoke((MethodInvoker)delegate
        //                {
        //                    lblDescription.Text = mensaje;
        //                });

        //                //if (element.Equals("UT"))

        //                ProcessNewElement(elementoMD, element, tipoElemento, ref cntErrores, ref cntExistentes);
        //            }
        //            catch (Exception ex)
        //            {
        //                Global.WriteToFile($"{addon}: ERROR al instalar complementos " + ex.Message);
        //            }
        //            finally
        //            {
        //                elementoMD = null;
        //            }
        //        }
        //    }
        //    finally
        //    {
        //        elemtsProcesar.Clear();
        //        //Cursor.Current = Cursors.Default;
        //    }

        //}

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
            //GC.Collect();
        }

        private void UpdateElement(dynamic existingField, string element, string tipoElemento, ref int cntErrores, ref int cntExistentes)
        {
            Global.WriteToFile(existingField.GetAsXML().ToString());

            if (existingField.Update() == 0)
            {
                HandleAddSuccess(element, tipoElemento, existingField);
            }
            else
            {
                HandleAddError(element, tipoElemento, existingField, ref cntErrores, ref cntExistentes);
            }

            // Asegúrate de liberar 'existingField' aquí si es necesario
            if (existingField != null)
            {
                System.Runtime.InteropServices.Marshal.ReleaseComObject(existingField);
                existingField = null;
            }

            //GC.Collect();
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

                                    if (ex.Message.Contains("Not recommended feature: using cursors in Scalar UDF"))
                                    {
                                         mensaje = $"{ps_addn}: Crear manualmente la función: {ls_NmbFile}";
                                        Global.WriteToFile(mensaje);
                                    }
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

                                    if (ex.Message.Contains("Not recommended feature: using cursors in Scalar UDF"))
                                    {
                                        mensaje = $"{ps_addn}: Crear manualmente la función: {ls_NmbFile}";
                                        Global.WriteToFile(mensaje);
                                    }
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

                                    if (ex.Message.Contains("Not recommended feature: using cursors in Scalar UDF"))
                                    {
                                        MessageBox.Show("No se obtuvo permiso de l a base de datos para" +
                                            "crear este procedimiento, ejecutar el siguiente query y reprocesar: \n" +
                                            "'alter system alter configuration ('indexserver.ini', 'system') set ('sqlscript', 'enable_select_into_scalar_udf') = 'true' with reconfigure;" +
                                            "\nalter system alter configuration ('indexserver.ini', 'system') set ('sqlscript', 'sudf_support_level_select_into') = 'silent' with reconfigure;" +
                                            "\nalter system alter configuration ('indexserver.ini', 'system') set ('sqlscript', 'dynamic_sql_ddl_error_level') = 'silent' with reconfigure;'", "Scripts", MessageBoxButtons.OK, MessageBoxIcon.Error);
                                        throw;
                                    }
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
            try
            {
                switch (addon)
                {
                    case "Letras":
                        ProcesarExcel($"{System.Windows.Forms.Application.StartupPath}\\Resources\\Letras\\DataDefecto.xlsm");
                        break;

                    case "Localizacion":
                        InicializarLocalizacion();
                        break;

                    case "CCHHE":
                        InicializarCCHHE();
                        break;

                    case "SIRE":
                        ProcesarExcel($"{System.Windows.Forms.Application.StartupPath}\\Resources\\Sire\\DataDefecto.xlsm");
                        break;

                    default:
                        MessageBox.Show("Addon no reconocido", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        break;
                }

                MessageBox.Show("Se terminó con la inicialización de la configuración", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                Global.WriteToFile($"{addon}: Se termino con la inicialización de la configuración");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error durante la inicialización del addon {addon}: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Global.WriteToFile($"Error en fn_inicializacion: {ex.Message}");
            }
        }

        private void ProcesarExcel(string path)
        {
            ms.Application excelApp = new ms.Application();
            Workbook workbook = excelApp.Workbooks.Open(path);

            try
            {
                foreach (Worksheet worksheet in workbook.Sheets)
                {
                    string tablaSAP = worksheet.Name;
                    if (!string.IsNullOrEmpty(tablaSAP) && tablaSAP != "Listas")
                    {
                        Microsoft.Office.Interop.Excel.Range usedRange = worksheet.UsedRange;

                        for (int row = 3; row < usedRange.Rows.Count; row++)
                        {
                            ProcesarFilaExcel(tablaSAP, usedRange, row);
                        }
                    }
                }
            }
            finally
            {
                workbook.Close(false);
                excelApp.Quit();
                System.Runtime.InteropServices.Marshal.ReleaseComObject(workbook);
                System.Runtime.InteropServices.Marshal.ReleaseComObject(excelApp);
                GC.Collect();
            }
        }

        private void ProcesarFilaExcel(string tablaSAP, Microsoft.Office.Interop.Excel.Range usedRange, int row)
        {
            try
            {
                SAPbobsCOM.UserTable userTable = company.UserTables.Item(tablaSAP);
                userTable.Code = $"{usedRange.Cells[row, 1].Value2}";
                userTable.Name = $"{usedRange.Cells[row, 2].Value2}";

                for (int col = 3; col <= usedRange.Columns.Count; col++)
                {
                    string campoSAP = usedRange.Cells[1, col].Value2;
                    if (!string.IsNullOrEmpty(campoSAP) && campoSAP != "Resultados")
                    {
                        var valor = (usedRange.Cells[row, col] as Microsoft.Office.Interop.Excel.Range).Value2;
                        userTable.UserFields.Fields.Item(campoSAP).Value = $"{valor}";

                        this.Invoke((MethodInvoker)delegate
                        {
                            string msj = $"Insert Data | Table: {tablaSAP} - Campo: {campoSAP} - Valor: {valor}";
                            lblDescription.Text = msj;
                            Global.WriteToFile(msj);
                        });
                    }
                }

                if (userTable.Add() != 0)
                {
                    company.GetLastError(out int errorCode, out string errorMessage);
                    MessageBox.Show($"Error al agregar el registro en {tablaSAP}: {errorMessage}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }

                System.Runtime.InteropServices.Marshal.ReleaseComObject(userTable);
                userTable = null;
            }
            catch (Exception ex)
            {
                Global.WriteToFile($"Error al procesar la fila {row} de la tabla {tablaSAP}: {ex.Message}");
            }
        }

        private void InicializarLocalizacion()
        {
            Sb_InsertarDataPorDefectoLocalizacion();
                
            if (MessageBox.Show("¿Deseas implementar el Maestro de las definiciones de Bancos?", "Maestros", MessageBoxButtons.YesNo, MessageBoxIcon.Information) == DialogResult.Yes)
            {
                ImplementarDefinicionesDeBancos();
            }

            //if (MessageBox.Show("¿Deseas implementar el Maestro de los Impuestos?", "Maestros", MessageBoxButtons.YesNo, MessageBoxIcon.Information) == DialogResult.Yes)
            //{
            //    ImplementarImpuestos();
            //}
        }

        private void ImplementarDefinicionesDeBancos()
        {
            try
            {
                string baseUrl = ConfigurationManager.AppSettings["link_api"];
                string endpoint = "/bankCodes";
                string apiUrl = $"{baseUrl}{endpoint}";

                HttpClient httpClient = new HttpClient();
                HttpResponseMessage response = httpClient.GetAsync(apiUrl).Result;
                response.EnsureSuccessStatusCode();

                string jsonResponse = response.Content.ReadAsStringAsync().Result;
                ConsultationResponse<List<CodigoBancario>> apiResponse = JsonSerializer.Deserialize<ConsultationResponse<List<CodigoBancario>>>(jsonResponse);

                if (apiResponse.CodRespuesta == "00" && apiResponse.Result != null)
                {
                    foreach (var bank in apiResponse.Result)
                    {
                        if (!BancoExiste(bank.BankCode, bank.CountryCod))
                        {
                            CrearBancoEnSAP(bank);
                        }
                        else
                        {
                            LogBancoExistente(bank);
                        }
                    }

                    MessageBox.Show("Definiciones de Bancos implementadas correctamente.", "Éxito", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show("Error en la respuesta del API.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error al implementar las definiciones de Bancos: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void ImplementarImpuestos()
        {
            try
            {
                string baseUrl = ConfigurationManager.AppSettings["link_api"];
                string endpoint = "/impuestos";
                string apiUrl = $"{baseUrl}{endpoint}";

                HttpClient httpClient = new HttpClient();
                HttpResponseMessage response = httpClient.GetAsync(apiUrl).Result;
                response.EnsureSuccessStatusCode();

                string jsonResponse = response.Content.ReadAsStringAsync().Result;
                ConsultationResponse<List<Impuesto>> apiResponse = JsonSerializer.Deserialize<ConsultationResponse<List<Impuesto>>>(jsonResponse);

                if (apiResponse.CodRespuesta == "00" && apiResponse.Result != null)
                {
                    foreach (var impuesto in apiResponse.Result)
                    {
                        if (!ImpuestoExiste(impuesto.WTCode))
                        {
                            CrearImpuestoEnSAP(impuesto);
                        }
                        else
                        {
                            LogImpuestoExistente(impuesto);
                        }
                    }

                    MessageBox.Show("Impuestos implementados correctamente.", "Éxito", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show("Error en la respuesta del API.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error al implementar los Impuestos: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private void CrearImpuestoEnSAP(Impuesto impuesto)
        {
            try
            {
                SAPbobsCOM.WithholdingTaxCodes oImpuesto = (SAPbobsCOM.WithholdingTaxCodes)company.GetBusinessObject(BoObjectTypes.oWithholdingTaxCodes);
                oImpuesto.WTCode = impuesto.WTCode;
                oImpuesto.WTName = impuesto.WTName;
                oImpuesto.Category = impuesto.Category == "P" ? WithholdingTaxCodeCategoryEnum.wtcc_Payment : WithholdingTaxCodeCategoryEnum.wtcc_Invoice;
                oImpuesto.BaseType = impuesto.BaseType == "N" ? WithholdingTaxCodeBaseTypeEnum.wtcbt_Net : WithholdingTaxCodeBaseTypeEnum.wtcbt_VAT;
                // oImpuesto.Rate = impuesto.Rate;
                oImpuesto.OfficialCode = impuesto.OffclCode;
                oImpuesto.Account = EsSegmentado() ? DefectCuentaSegmentada() : DefectCuentaNoSegmentada();
                ///oImpuesto. = DateTime.Now;
                //oImpuesto.Inactive = impuesto.Inactive == "Y" ? SAPbobsCOM.BoYesNoEnum.tYES : SAPbobsCOM.BoYesNoEnum.tNO;
                oImpuesto.UserFields.Fields.Item("U_RetImp").Value = impuesto.U_RetImp == "Y" ? "Y" : "N";

                if (oImpuesto.Add() != 0)
                {
                    company.GetLastError(out int errorCode, out string errorMessage);
                    this.Invoke((MethodInvoker)delegate
                    {
                        string msj = $"Error al agregar el impuesto {impuesto.WTName}: {errorMessage}";
                        lblDescription.Text = msj;
                        Global.WriteToFile(msj);
                    });
                }
            }
            catch (Exception ex)
            {
                Global.WriteToFile($"Error al agregar el impuesto {impuesto.WTName}: {ex.Message}");
            }
        }
        private void LogImpuestoExistente(Impuesto impuesto)
        {
            this.Invoke((MethodInvoker)delegate
            {
                string msj = $"El impuesto {impuesto.WTName} ya existe en SAP.";
                lblDescription.Text = msj;
                Global.WriteToFile(msj);
            });
        }
        private bool ImpuestoExiste(string wtCode)
        {
            SAPbobsCOM.Recordset recordset = company.GetBusinessObject(BoObjectTypes.BoRecordset);
            recordset.DoQuery($"SELECT 1 FROM OWHT WHERE \"WTCode\" = '{wtCode}'");

            bool exists = !recordset.EoF;

            System.Runtime.InteropServices.Marshal.ReleaseComObject(recordset);
            GC.Collect();

            return exists;
        }

        private bool EsSegmentado()
        {
            SAPbobsCOM.Recordset recordset = company.GetBusinessObject(BoObjectTypes.BoRecordset);
            recordset.DoQuery($"SELECT  1 FROM CINF WHERE \"EnbSgmnAct\" = 'Y'");

            bool exists = !recordset.EoF;

            System.Runtime.InteropServices.Marshal.ReleaseComObject(recordset);
            GC.Collect();

            return exists;
        }
        private string DefectCuentaSegmentada()
        {
            SAPbobsCOM.Recordset recordset = company.GetBusinessObject(BoObjectTypes.BoRecordset);
            try
            { 
                recordset.DoQuery($"SELECT TOP 1 \"AcctCode\" as \"Cuenta\" FROM \"OACT\" WHERE \"Segment_0\" LIKE '4%' and \"AcctName\" LIKE '%IGV%'");
                return recordset.Fields.Item(0).Value;
            }
            catch (Exception)
            {
                throw;
            } finally
            {
              
                System.Runtime.InteropServices.Marshal.ReleaseComObject(recordset);
                GC.Collect();
            }

          
        }
        private string DefectCuentaNoSegmentada()
        {
            try { 
            SAPbobsCOM.Recordset recordset = company.GetBusinessObject(BoObjectTypes.BoRecordset);
            recordset.DoQuery($"SELECT TOP 1 \"AcctCode\" FROM \"OACT\" WHERE \"AcctCode\" LIKE '4%' and \"AcctName\" LIKE '%IGV%'");

            return recordset.Fields.Item(0).Value;
             } finally
            {
                GC.Collect();
            }
        }
        private void CrearBancoEnSAP(CodigoBancario bank)
        {
            Banks oBank = (Banks)company.GetBusinessObject(BoObjectTypes.oBanks);
            oBank.CountryCode = bank.CountryCod;
            oBank.BankCode = bank.BankCode;
            oBank.BankName = bank.BankName;

            if (oBank.Add() != 0)
            {
                company.GetLastError(out int errorCode, out string errorMessage);
                this.Invoke((MethodInvoker)delegate
                {
                    string msj = $"Error al agregar el banco {bank.BankName}: {errorMessage}";
                    lblDescription.Text = msj;
                    Global.WriteToFile(msj);
                });
            }
        }

        private void LogBancoExistente(CodigoBancario bank)
        {
            this.Invoke((MethodInvoker)delegate
            {
                string msj = $"El banco {bank.BankName} ya existe en SAP.";
                lblDescription.Text = msj;
                Global.WriteToFile(msj);
            });
        }

        private void InicializarCCHHE()
        {
            SAPbobsCOM.Recordset lo_RecSet = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.BoRecordset);
            SAPbobsCOM.UserTablesMD lo_UsrTblMD = company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oUserTables);

            if (lo_UsrTblMD.GetByKey("STR_CCHEAR_SYS"))
            {
                SAPbobsCOM.UserTable lo_UsrTbl = company.UserTables.Item("STR_CCHEAR_SYS");
                string ls_Qry = @"SELECT ""U_CE_ID"" FROM ""@STR_CCHEAR_SYS""";
                lo_RecSet.DoQuery(ls_Qry);

                if (lo_RecSet.EoF)
                {
                    lo_UsrTbl.Code = "001";
                    lo_UsrTbl.Name = "001";
                    lo_UsrTbl.UserFields.Fields.Item("U_CE_ID").Value = "1";
                    lo_UsrTbl.Add();
                }
            }

            System.Runtime.InteropServices.Marshal.ReleaseComObject(lo_RecSet);
            System.Runtime.InteropServices.Marshal.ReleaseComObject(lo_UsrTblMD);
            GC.Collect();
        }

        // Método para validar si un banco ya existe en la tabla ODSC
        public bool BancoExiste(string bankCode, string countryCod)
        {
            bool exists = false;
            Recordset oRecordset = (Recordset)company.GetBusinessObject(BoObjectTypes.BoRecordset);

            string query = $"SELECT COUNT(*) FROM ODSC WHERE \"BankCode\" = '{bankCode}' AND \"CountryCod\" = '{countryCod}'";
            oRecordset.DoQuery(query);

            if (oRecordset != null && !oRecordset.EoF)
            {
                int count = oRecordset.Fields.Item(0).Value;
                exists = count > 0;
            }

            System.Runtime.InteropServices.Marshal.ReleaseComObject(oRecordset);
            oRecordset = null;
            GC.Collect();

            return exists;
        }
        public void Sb_InsertarDataPorDefectoLocalizacion()
        {
            try
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
                                        if (!string.IsNullOrWhiteSpace(campoSAP))
                                        {
                                            var valor = (usedRange.Cells[row, col] as Microsoft.Office.Interop.Excel.Range).Value2;

                                            this.Invoke((MethodInvoker)delegate
                                            {
                                                string msj = $"Insert Data | Table: {tablaSAP} - Campo: {campoSAP} - Valor: {valor}";
                                                lblDescription.Text = msj;
                                                Global.WriteToFile(msj);
                                            });

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
                excelApp.Workbooks.Close();
            }
            catch (Exception)
            {
                throw;
            }
        }
        public void Sb_InsertarBancosDefiniciones()
        {
            try
            {
                SAPbobsCOM.Banks ds = (SAPbobsCOM.Banks)company.GetBusinessObject(SAPbobsCOM.BoObjectTypes.oBanks);
                ds.CountryCode = "";
                ds.BankCode = "";
                ds.BankName = "";

            }
            catch (Exception)
            {
                throw;
            }
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
