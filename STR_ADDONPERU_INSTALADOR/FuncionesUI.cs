using MaterialSkin.Controls;
using STR_ADDONPERU_INSTALADOR.EL.Requests;
using STR_ADDONPERU_INSTALADOR.EL.Responses;
using STR_ADDONPERU_INSTALADOR.Services;
using STR_ADDONPERU_INSTALADOR.Util;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;

namespace STR_ADDONPERU_INSTALADOR
{
    public class FuncionesUI
    {
        public List<B1SLUserTablesMD> b1SLUserTablesMDs = new List<B1SLUserTablesMD>();
        public List<B1SLUserFieldsMD> b1SLUserFieldsMDs = new List<B1SLUserFieldsMD>();
        public List<B1SLUserObjectsMD> b1SLUserObjectsMDs = new List<B1SLUserObjectsMD>();
        public CountTable obtenerTablas(string addon)
        {
            try
            {
                int validados = 0;
                int faltantes = 0;

                string path = $"{Application.StartupPath}\\Resources\\{addon}\\UT.vte";

                XmlDocument xdoc = new XmlDocument();
                xdoc.Load(path);


                XmlNodeList tableNameNodes = xdoc.SelectNodes("//UserTablesMD/row");

                foreach (XmlNode tableNameNode in tableNameNodes)
                {
                    string tableName = tableNameNode.SelectSingleNode("TableName")?.InnerText;
                    string tableDescription = tableNameNode.SelectSingleNode("TableDescription")?.InnerText;
                    string tableType = tableNameNode.SelectSingleNode("TableType")?.InnerText;
                    if (SLEndpoint.validationTable(tableName))
                        validados++;
                    else
                    {
                        B1SLUserTablesMD b1SLUserTablesMD = new B1SLUserTablesMD();
                        b1SLUserTablesMD.TableName = tableName;
                        b1SLUserTablesMD.TableDescription = tableDescription;
                        b1SLUserTablesMD.TableType = tableType;

                        b1SLUserTablesMDs.Add(b1SLUserTablesMD);

                        faltantes++;
                    }
                }
                CountTable countTable = new CountTable()
                {
                    validadas = validados,
                    faltantes = faltantes,
                    total = tableNameNodes.Count
                };

                return countTable;
            }
            catch (IOException ex)
            {
                Global.WriteToFile($"{addon} - Error de entrada/salida: " + ex.Message);
                throw new Exception($"{addon} - Error de entrada/salida: " + ex.Message);
            }
            catch (UnauthorizedAccessException ex)
            {
                Global.WriteToFile($"{addon} - Acceso no autorizado: " + ex.Message);
                throw new Exception($"{addon} - Acceso no autorizado: " + ex.Message);
            }
            catch (Exception e)
            {
                Global.WriteToFile($"{addon} - Error al validar tablas, mensaje de SAP: {e.Message}");
                throw new Exception($"{addon} - Error al validar tablas, mensaje de SAP: {e.Message}");
            }
        }

        public CountTable obtenerColumnas(string addon)
        {
            try
            {
                int validados = 0;
                int faltantes = 0;

                string path = $"{Application.StartupPath}\\Resources\\{addon}\\UF.vte";

                XmlDocument xdoc = new XmlDocument();
                xdoc.Load(path);

                XmlNodeList tableNameNodes = xdoc.SelectNodes("//UserFieldsMD/row");

                foreach (XmlNode tableNameNode in tableNameNodes)
                {
                    string name = tableNameNode.SelectSingleNode("Name")?.InnerText;
                    string tableName = tableNameNode.SelectSingleNode("TableName")?.InnerText;
                    if (SLEndpoint.validationColumn(tableName, name))
                        validados++;
                    else
                    {
                        B1SLUserFieldsMD b1SLUserFieldsMD = new B1SLUserFieldsMD();
                        b1SLUserFieldsMD.Name = name;
                        b1SLUserFieldsMD.Type = tableNameNode.SelectSingleNode("Type")?.InnerText;
                        b1SLUserFieldsMD.Size = Convert.ToInt32(tableNameNode.SelectSingleNode("Size")?.InnerText);
                        b1SLUserFieldsMD.Description = tableNameNode.SelectSingleNode("Description")?.InnerText;
                        b1SLUserFieldsMD.SubType = tableNameNode.SelectSingleNode("SubType")?.InnerText;
                        b1SLUserFieldsMD.TableName = tableName;
                        b1SLUserFieldsMD.EditSize = Convert.ToInt32(tableNameNode.SelectSingleNode("EditSize")?.InnerText);
                        b1SLUserFieldsMD.Mandatory = tableNameNode.SelectSingleNode("Mandatory")?.InnerText;
                        b1SLUserFieldsMDs.Add(b1SLUserFieldsMD);

                        faltantes++;
                    }
                }

                CountTable countTable = new CountTable()
                {
                    validadas = validados,
                    faltantes = faltantes,
                    total = tableNameNodes.Count
                };

                return countTable;
            }
            catch (IOException ex)
            {
                Global.WriteToFile($"{addon} - Error de entrada/salida: " + ex.Message);
                throw new Exception($"{addon} - Error de entrada/salida: " + ex.Message);
            }
            catch (UnauthorizedAccessException ex)
            {
                Global.WriteToFile($"{addon} - Acceso no autorizado: " + ex.Message);
                throw new Exception($"{addon} - Acceso no autorizado: " + ex.Message);
            }
            catch (Exception e)
            {
                Global.WriteToFile($"{addon} - Error al validar columnas, mensaje de SAP: {e.Message}");
                throw new Exception($"{addon} - Error al validar columnas, mensaje de SAP: {e.Message}");
            }
        }

        public CountTable obtenerObjects(string addon)
        {
            try
            {
                int validados = 0;
                int faltantes = 0;

                string path = $"{Application.StartupPath}\\Resources\\{addon}\\UO.vte";

                XmlDocument xdoc = new XmlDocument();
                xdoc.Load(path);

                XmlNodeList tableNameNodes = xdoc.SelectNodes("//BO");

                if (tableNameNodes.Count == 0)
                {
                    // El archivo UO.vte está vacío, devolver CountTable con valores en cero
                    return new CountTable()
                    {
                        validadas = 0,
                        faltantes = 0,
                        total = 0
                    };
                }

                foreach (XmlNode boNode in tableNameNodes)
                {
                    XmlNode admInfoNode = boNode.SelectSingleNode("AdmInfo/Object");

                    // OUDO Node
                    XmlNode oudoNode = boNode.SelectSingleNode("OUDO/row");
                    if (oudoNode != null)
                    {
                        string objectId = oudoNode.SelectSingleNode("Code")?.InnerText;

                        if (SLEndpoint.validationObjectsMD(objectId))
                        {
                            validados++;
                        }
                        else
                        {

                            faltantes++;

                            B1SLUserObjectsMD b1SLUserObjectsMD = new B1SLUserObjectsMD
                            {
                                Code = objectId,
                                Name = oudoNode.SelectSingleNode("Name")?.InnerText,
                                TableName = oudoNode.SelectSingleNode("TableName")?.InnerText,
                                ObjectType = Convert.ToInt32(oudoNode.SelectSingleNode("TYPE")?.InnerText),
                                ManageSeries = oudoNode.SelectSingleNode("MngSeries")?.InnerText,
                                CanFind = oudoNode.SelectSingleNode("CanFind")?.InnerText,
                                CanYearTransfer = oudoNode.SelectSingleNode("CanYrTrnsf")?.InnerText,
                                CanCreateDefaultForm = oudoNode.SelectSingleNode("CanDefForm")?.InnerText,
                                CanCancel = oudoNode.SelectSingleNode("CanCancel")?.InnerText,
                                CanDelete = oudoNode.SelectSingleNode("CanDelete")?.InnerText,
                                CanLog = oudoNode.SelectSingleNode("CanLog")?.InnerText,
                            };

                            // UDO1 Node
                            XmlNodeList udo1Nodes = boNode.SelectNodes("UDO1/row");
                            if (udo1Nodes != null)
                            {
                                foreach (XmlNode udo1Node in udo1Nodes)
                                {
                                    UserObjectMD_ChildTable userObjectMD_ChildTable = new UserObjectMD_ChildTable()
                                    {
                                        TableName = udo1Node.SelectSingleNode("TableName")?.InnerText,
                                        ObjectName = udo1Node.SelectSingleNode("TableName")?.InnerText
                                    };

                                    b1SLUserObjectsMD.UserObjectMD_ChildTables.Add(userObjectMD_ChildTable);
                                };
                            }
                            XmlNodeList udo2Nodes = boNode.SelectNodes("UDO2/row");

                            if (udo2Nodes != null)
                            {
                                foreach (XmlNode udo2Node in udo2Nodes)
                                {
                                    string colAlias = udo2Node.SelectSingleNode("ColAlias")?.InnerText;
                                    string columnDesc = udo2Node.SelectSingleNode("ColumnDesc")?.InnerText;

                                    // Realizar operaciones con colAlias y columnDesc
                                    // Por ejemplo, puedes crear una instancia de una clase y agregarla a una lista
                                    UserObjectMD_FindColumn udo2Column = new UserObjectMD_FindColumn
                                    {
                                        ColumnAlias = colAlias,
                                        ColumnDescription = columnDesc
                                    };

                                    // Agregar a una lista o realizar otras operaciones según tus necesidades
                                    b1SLUserObjectsMD.UserObjectMD_FindColumns.Add(udo2Column);
                                }
                            }
                            b1SLUserObjectsMDs.Add(b1SLUserObjectsMD);

                        }
                    }
                }

                CountTable countTable = new CountTable()
                {
                    validadas = validados,
                    faltantes = faltantes,
                    total = tableNameNodes.Count
                };

                return countTable;
            }
            catch (IOException ex)
            {
                Global.WriteToFile($"{addon} - Error de entrada/salida: " + ex.Message);
                throw new Exception($"{addon} - Error de entrada/salida: " + ex.Message);
            }
            catch (UnauthorizedAccessException ex)
            {
                Global.WriteToFile($"{addon} - Acceso no autorizado: " + ex.Message);
                throw new Exception($"{addon} - Acceso no autorizado: " + ex.Message);
            }
            catch (Exception e)
            {
                Global.WriteToFile($"{addon} - Error al validar objetos, mensaje de SAP: {e.Message}");
                throw new Exception($"{addon} - Error al validar objetos, mensaje de SAP: {e.Message}");
            }
        }

        //public CountTable crearTabla(CountTable countTable, string addon)
        //{

        //}
    }
}
