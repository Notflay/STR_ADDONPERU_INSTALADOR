using STR_ADDONPERU_INSTALADOR.Services;
using STR_ADDONPERU_INSTALADOR.Util;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace STR_ADDONPERU_INSTALADOR
{
    public partial class FrmInit : Form
    {
        public FrmInit()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Global.servidor = txtServidor.Text;
            Global.nombre = txtNombre.Text;
            Global.usuario = txtUsuario.Text;
            Global.password = txtPassword.Text;

            SLConnection sLConnection = new SLConnection();
            bool valid = sLConnection.connection();

            if (valid)
            {
                if (MessageBox.Show($"Usuario registrado correctamente", "Registor de Sesion", MessageBoxButtons.OK, MessageBoxIcon.Information) == DialogResult.OK)
                {
                    // Oculta la ventana actual
                    this.Hide();

                    // Abre el nuevo formulario FrmMenu
                    FrmMenu frmMenu = new FrmMenu();
                    frmMenu.FormClosed += (s, args) => this.Close(); // Cierra la aplicación cuando se cierre FrmMenu
                    frmMenu.Show();
                }
            }
            else
            {
                MessageBox.Show("Credenciales invalidas", "Registor de Sesion", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void txtServidor_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtNombre_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtUsuario_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtPassword_TextChanged(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }
    }
}
