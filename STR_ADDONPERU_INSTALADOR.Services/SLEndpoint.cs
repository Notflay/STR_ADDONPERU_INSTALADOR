using RestSharp;
using STR_ADDONPERU_INSTALADOR.EL.Requests;
using STR_ADDONPERU_INSTALADOR.EL.Responses;
using STR_ADDONPERU_INSTALADOR.Util;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;

namespace STR_ADDONPERU_INSTALADOR.Services
{
    public static class SLEndpoint
    {


        public static bool validationTable(string table)
        {
            try
            {

                string url = SLConnection.getBasePath();
                ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                var client = new RestClient(url);
                var request = new RestRequest($"UserTablesMD('{table}')", Method.GET);
                request.AddHeader("content-type", "application/json");
                request.AddCookie("B1SESSION", Global.SessionId);
                request.AddCookie("ROUTEID", ".node0");
                //request.AddJsonBody(null);
                var response = client.Execute(request);

                if (response.StatusCode == HttpStatusCode.Unauthorized)
                {
                    if (SLConnection.TryReauthenticate())
                    {
                        response = client.Execute(request);

                        if (response.IsSuccessful)
                        {
                            return true;
                        }
                    }

                    return false;
                }
                else if (response.IsSuccessful)
                {
                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                return false;
            }
        }


        public static bool validationColumn(string table, string columna)
        {
            try
            {
                string filtro = $"TableName='{table}',FieldID={columna}";
                string url = SLConnection.getBasePath();
                ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                var client = new RestClient(url);
                var request = new RestRequest($"UserFieldsMD({filtro})", Method.GET);
                request.AddHeader("content-type", "application/json");
                request.AddCookie("B1SESSION", Global.SessionId);
                request.AddCookie("ROUTEID", ".node0");
                //request.AddJsonBody(null);
                var response = client.Execute(request);

                if (response.StatusCode == HttpStatusCode.Unauthorized)
                {
                    if (SLConnection.TryReauthenticate())
                    {
                        response = client.Execute(request);

                        if (response.IsSuccessful)
                        {
                            return true;
                        }
                    }

                    return false;
                }
                else if (response.IsSuccessful)
                {
                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        public static bool validationObject(string objectId)
        {
            try
            {
                string url = SLConnection.getBasePath();
                ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                var client = new RestClient(url);
                var request = new RestRequest($"UserObjectsMD('{objectId}')", Method.GET);
                request.AddHeader("content-type", "application/json");
                request.AddCookie("B1SESSION", Global.SessionId);
                request.AddCookie("ROUTEID", ".node0");
                //request.AddJsonBody(null);
                var response = client.Execute(request);

                if (response.StatusCode == HttpStatusCode.Unauthorized)
                {
                    if (SLConnection.TryReauthenticate())
                    {
                        response = client.Execute(request);

                        if (response.IsSuccessful)
                        {
                            return true;
                        }
                    }

                    return false;
                }
                else if (response.IsSuccessful)
                {
                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                return false;
            }
        }


        public static CountTable CrearTabla(B1SLUserTablesMD tabla, CountTable countTable, string addon)
        {
            try
            {
                string url = SLConnection.getBasePath();
                ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                var client = new RestClient(url);
                var request = new RestRequest($"UserTablesMD", Method.POST);
                request.AddHeader("content-type", "application/json");
                request.AddCookie("B1SESSION", Global.SessionId);
                request.AddCookie("ROUTEID", ".node0");
                request.AddJsonBody(tabla);

                IRestResponse response = null;

                for (int attempt = 0; attempt < 2; attempt++) // Intentar dos veces en caso de Unauthorized o BadGateway
                {
                    response = client.Execute(request);

                    if (response.IsSuccessful)
                    {
                        countTable.faltantes -= 1;
                        Global.WriteToFile($"{addon} - {tabla.TableName} - Tabla Creada exitosamente");
                        return countTable;
                    }

                    if (response.StatusCode == HttpStatusCode.Unauthorized || response.StatusCode == HttpStatusCode.BadGateway)
                    {
                        if (!SLConnection.TryReauthenticate())
                        {
                            Global.WriteToFile($"{addon} - {tabla.TableName} - Error: No se pudo crear tabla por problemas de autenticación");
                            return countTable;
                        }
                    }
                    else
                    {
                        break;
                    }
                }

                B1SLError b1SLError = JsonSerializer.Deserialize<B1SLError>(response.Content);
                Global.WriteToFile($"{addon} - {tabla.TableName} - Error: No se pudo crear tabla - Mensaje SAP: {b1SLError.error.message.value}");
                return countTable;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
        }

        public static CountTable CrearColumna(B1SLUserFieldsMD columna, CountTable countTable, string addon)
        {
            try
            {
                string url = SLConnection.getBasePath();
                ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                var client = new RestClient(url);
                var request = new RestRequest($"UserFieldsMD", Method.POST);
                request.AddHeader("content-type", "application/json");
                request.AddCookie("B1SESSION", Global.SessionId);
                request.AddCookie("ROUTEID", ".node0");
                request.AddJsonBody(columna);

                IRestResponse response = null;

                for (int attempt = 0; attempt < 2; attempt++) // Intentar dos veces en caso de Unauthorized o BadGateway
                {
                    response = client.Execute(request);

                    if (response.IsSuccessful)
                    {
                        countTable.faltantes -= 1;
                        Global.WriteToFile($"{addon} - {columna.Name} - Columna Creada exitosamente");
                        return countTable;
                    }

                    if (response.StatusCode == HttpStatusCode.Unauthorized || response.StatusCode == HttpStatusCode.BadGateway)
                    {
                        if (!SLConnection.TryReauthenticate())
                        {
                            Global.WriteToFile($"{addon} - {columna.Name} - Error: No se pudo crear la columna por problemas de autenticación");
                            return countTable;
                        }
                    }
                    else
                    {
                        break;
                    }
                }

                B1SLError b1SLError = JsonSerializer.Deserialize<B1SLError>(response.Content);
                Global.WriteToFile($"{addon} - {columna.Name} - Error: No se pudo crear Columna - Mensaje SAP: {b1SLError.error.message.value}");
                return countTable;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
        }


        public static CountTable CrearObjeto(B1SLUserObjectsMD objeto, CountTable countTable, string addon)
        {
            try
            {
                string url = SLConnection.getBasePath();
                ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                var client = new RestClient(url);
                var request = new RestRequest($"UserTablesMD", Method.POST);
                request.AddHeader("content-type", "application/json");
                request.AddCookie("B1SESSION", Global.SessionId);
                request.AddCookie("ROUTEID", ".node0");
                request.AddJsonBody(objeto);

                IRestResponse response = null;

                for (int attempt = 0; attempt < 2; attempt++) // Intentar dos veces en caso de Unauthorized o BadGateway
                {
                    response = client.Execute(request);

                    if (response.IsSuccessful)
                    {
                        countTable.faltantes -= 1;
                        Global.WriteToFile($"{addon} - {objeto.Code} - Objeto Creada exitosamente");
                        return countTable;
                    }

                    if (response.StatusCode == HttpStatusCode.Unauthorized || response.StatusCode == HttpStatusCode.BadGateway)
                    {
                        if (!SLConnection.TryReauthenticate())
                        {
                            Global.WriteToFile($"{addon} - {objeto.Code} - Error: No se pudo crear objeto por problemas de autenticación");
                            return countTable;
                        }
                    }
                    else
                    {
                        break;
                    }
                }

                B1SLError b1SLError = JsonSerializer.Deserialize<B1SLError>(response.Content);
                Global.WriteToFile($"{addon} - {objeto.Code} - Error: No se pudo crear objeto - Mensaje SAP: {b1SLError.error.message.value}");
                return countTable;
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
        }

    }
}
