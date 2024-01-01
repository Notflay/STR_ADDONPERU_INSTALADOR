using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace STR_ADDONPERU_INSTALADOR
{
    internal static class Program
    {
        /// <summary>
        /// Punto de entrada principal para la aplicación.
        /// </summary>
        [STAThread]
        static void Main()
        {
            if (MessageBox.Show("¿Conectarse al SAP que se está ejecutando?", "Conexión SAP", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                FuncionesUI funciones = new FuncionesUI();
                if (funciones.conectionString())
                {
                    Application.EnableVisualStyles();
                    Application.SetCompatibleTextRenderingDefault(false);
                    Application.Run(new FrmInstalador(funciones.sboCompany));
                }
                else
                    MessageBox.Show("No se establecio conexión con SAP. Recuerde que tiene que tener el programa abierto", "Error SAP", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            else
                Application.Run(new Login());
        }
    }
}
