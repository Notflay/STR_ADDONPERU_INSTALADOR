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




        }

        private void materialLabel1_Click(object sender, EventArgs e)
        {

        }

        private void txtUsuario_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
