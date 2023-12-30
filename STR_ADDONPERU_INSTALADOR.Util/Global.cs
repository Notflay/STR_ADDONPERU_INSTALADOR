using System;
using System.IO;

namespace STR_ADDONPERU_INSTALADOR.Util
{
    public static class Global
    {

        public static string servidor = "";
        public static string nombre = "";
        public static string usuario = "";
        public static string password = "";

        public static string SessionId;

        public static void WriteToFile(string Message)
        {
            string path = AppDomain.CurrentDomain.BaseDirectory + "\\Logs";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            string filepath = $"{AppDomain.CurrentDomain.BaseDirectory}\\Logs\\Service_Creation_Log_{DateTime.Now.Date.ToShortDateString().Replace('/', '_')}.txt";
            if (!File.Exists(filepath))
            {
                using (StreamWriter sw = File.CreateText(filepath))
                {
                    sw.WriteLine(DateTime.Now.ToString() + " - " + Message);
                }
            }
            else
            {
                using (StreamWriter sw = File.AppendText(filepath))
                {
                    sw.WriteLine(DateTime.Now.ToString() + " - " + Message);
                }
            }
        }

        public enum PeruAddon
        {
            Localizacion = 1,
            Sire = 2,
            CCHHE = 3,
            Letras = 4
        }
    }
}
