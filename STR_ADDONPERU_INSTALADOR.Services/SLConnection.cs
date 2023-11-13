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

namespace STR_ADDONPERU_INSTALADOR.Services
{
    public class SLConnection
    {
        public SLConnection()
        {




        }

        public bool connection()
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
                B1SLLoginResponse response = JsonSerializer.Deserialize<B1SLLoginResponse>(client.Execute(request).Content);
                if (response.SessionId != null)
                {
                    Global.SessionId = response.SessionId;
                    return true;
                }
                throw new UnauthorizedAccessException();

            }
            catch (Exception ex)
            {

                return false;
            }

        }

        public string getBasePath()
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
