using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using MaterialSkin.Controls;
using RestSharp.Serialization.Json;
using STR_ADDONPERU_INSTALADOR.EL;
using STR_ADDONPERU_INSTALADOR.EL.Responses;
using STR_ADDONPERU_INSTALADOR.Services;
using STR_ADDONPERU_INSTALADOR.Util;

namespace STR_ADDONPERU_INSTALADOR
{
    public partial class Login : MaterialForm
    {
        private readonly MaterialSkin.MaterialSkinManager materialSkinManager;
        public Login()
        {
            InitializeComponent();

            materialSkinManager = MaterialSkin.MaterialSkinManager.Instance;
            materialSkinManager.EnforceBackcolorOnAllComponents = true;
            materialSkinManager.AddFormToManage(this);
            materialSkinManager.Theme = MaterialSkin.MaterialSkinManager.Themes.LIGHT;
            materialSkinManager.ColorScheme = new MaterialSkin.ColorScheme(MaterialSkin.Primary.Green500, MaterialSkin.Primary.Green700, MaterialSkin.Primary.LightGreen100, MaterialSkin.Accent.Green700, MaterialSkin.TextShade.WHITE);
        }

        private void materialButton11_Click(object sender, EventArgs e)
        {
            Global.servidor = txtServidor.Text;
            Global.nombre = txtNombre.Text;
            Global.usuario = txtUsuario.Text;
            Global.password = txtPassword.Text;

            var valid = SLConnection.fn_connection();



            if (valid.IsSuccessful)
            {
                if (MessageBox.Show($"Sesión exitosa, \"SessionId\" guardada", "Inicio de Sesión", MessageBoxButtons.OK, MessageBoxIcon.Information) == DialogResult.OK)
                {
                    // Oculta la ventana actual
                    this.Hide();
<<<<<<< HEAD
                    SLConnection.saveConnection();
=======
>>>>>>> e2ad822136580153e604004bc990ee412211e4b6

                    FrmInstalador frmInstalador = new FrmInstalador();
                    frmInstalador.ShowDialog();
                }
            }
            else
            {
                if (valid.StatusCode == 0)
                    MessageBox.Show("No se encuentra o no existe servidor", "Error de conexión", MessageBoxButtons.OK, MessageBoxIcon.Error);
                else
                {
                    B1SLError b1SLError = System.Text.Json.JsonSerializer.Deserialize<B1SLError>(valid.Content);

                    if (b1SLError.error.code == -315)
                        MessageBox.Show("Credenciales invalidas", "Inicio de Sesión", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    else
                    {
                        MessageBox.Show(b1SLError.error.message.value, "Inicio de Sesión", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
        }

        private void materialLabel1_Click(object sender, EventArgs e)
        {

        }
    }
}
