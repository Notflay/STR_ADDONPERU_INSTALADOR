using STR_ADDONPERU_INSTALADOR.Util;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Net;
using RestSharp;
using System.Security.Policy;
using System.Web.Configuration;
using STR_ADDONPERU_INSTALADOR.EL;
using System.Text.Json.Serialization;
using System.Text.Json;
using STR_ADDONPERU_INSTALADOR.EL.Responses;

namespace STR_ADDONPERU_INSTALADOR.Services
{
    public static class SLConnection
    {

        public static bool TryReauthenticate(int maxAttempts = 3)
        {
            for (int attempt = 1; attempt <= maxAttempts; attempt++)
            {
                try
                {
                    // Intentar volver a autenticar
                    if (fn_connection().IsSuccessful) // Asumiendo que este método realiza el inicio de sesión
                        return true;
                }
                catch (Exception ex)
                {
                    // Manejar errores o registrar información de intento de inicio de sesión fallido
                }
            }

            // Si todos los intentos fallan, devuelve false
            return false;
        }
        public static IRestResponse fn_connection()
        {
            try
            {
                string url = getBasePath();

                string usuario = Global.usuario;
                string pass = Global.password;
                string nombre = Global.nombre;

                ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, sslPolicyErrors) => true;
                var client = new RestClient(url);
                var request = new RestRequest("Login", Method.POST);
                request.AddHeader("content-type", "application/json");
                request.AddCookie("B1SESSION", string.Empty);
                request.AddCookie("ROUTEID", ".node0");
                request.AddJsonBody(new { CompanyDB = nombre, UserName = usuario, Password = pass });
                var response = client.Execute(request);

                if (response.IsSuccessful)
                {
                    Global.SessionId = JsonSerializer.Deserialize<B1SLLoginResponse>(response.Content).SessionId;
                    return response;
                }
                else
                {
                    return response;
                }
            }
            catch (Exception ex)
            {
                Global.WriteToFile(ex.ToString());
                throw new Exception(ex.Message);
            }

        }

        public static string getBasePath()
        {
            return new UriBuilder()
            {
                Scheme = WebConfigurationManager.AppSettings["Scheme"],
                Host = Global.servidor,
                Port = Convert.ToInt32(WebConfigurationManager.AppSettings["Port"]),
                Path = WebConfigurationManager.AppSettings["BasePath"]
            }.ToString();
        }
    }
}
