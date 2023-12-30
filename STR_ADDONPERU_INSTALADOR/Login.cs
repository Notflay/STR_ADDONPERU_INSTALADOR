using System;
using System.Windows.Forms;
using MaterialSkin.Controls;
using SAPbobsCOM;
using STR_ADDONPERU_INSTALADOR.Util;

namespace STR_ADDONPERU_INSTALADOR
{
    public partial class Login : MaterialForm
    {
        private SAPbobsCOM.Company company = null;
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


            string servidor = edtServidor.Text;
            string nombre = edtNombreDB.Text;
            string usuarioDB = edtUsuarioDB.Text;
            string passDB = edtPassDB.Text;
            string tipoDB = cbxTipoDB.Text;
            string usuarioSAP = edtUsuarioS.Text;
            string passSAP = edtPassS.Text;

            try
            {
                if (!string.IsNullOrEmpty(servidor) & !string.IsNullOrEmpty(nombre) & !string.IsNullOrEmpty(usuarioDB) &
                    !string.IsNullOrEmpty(passDB) & !string.IsNullOrEmpty(tipoDB) & !string.IsNullOrEmpty(usuarioSAP) &
                    !string.IsNullOrEmpty(passSAP))
                {
                    company = new SAPbobsCOM.Company();

                    company.Server = servidor;
                    company.CompanyDB = nombre;
                    company.DbUserName = usuarioDB;
                    company.DbPassword = passDB;
                    company.DbServerType = getTypeDB(tipoDB);
                    company.UserName = usuarioSAP;
                    company.Password = passSAP;

                    if (company.Connect() == 0)
                    {
                        MessageBox.Show("Conexión a SAP exitosamente", "Exitoso", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        Global.WriteToFile("Conexión a SAP exitosamente");

                        // Se crea una nueva instancia del formulario FrmInstalador
                        FrmInstalador frmInstalador = new FrmInstalador(company);

                        // Se oculta el formulario actual en lugar de cerrarlo
                        this.Hide();

                        // Se muestra el nuevo formulario
                        frmInstalador.Show();
                    }
                    else throw new Exception(company.GetLastErrorDescription());
                }
                else
                    throw new Exception("No se completó todos los datos para la conexión");
            }
            catch (Exception r)
            {
                MessageBox.Show(r.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

        }
        public BoDataServerTypes getTypeDB(string tipoDB)
        {

            try
            {
                switch (tipoDB)
                {
                    case "HANADB":
                        return BoDataServerTypes.dst_HANADB;
                    case "MSSQL2008":
                        return BoDataServerTypes.dst_MSSQL2008;
                    case "MSSQL2012":
                        return BoDataServerTypes.dst_MSSQL2012;
                    case "MSSQL2014":
                        return BoDataServerTypes.dst_MSSQL2014;
                    case "MSSQL2016":
                        return BoDataServerTypes.dst_MSSQL2016;
                    case "MSSQL2017":
                        return BoDataServerTypes.dst_MSSQL2017;
                    default:
                        throw new Exception("Error al obtener el tipo de Base de datos");
                }
            }
            catch (Exception e)
            {
                Global.WriteToFile(e.Message);
                throw;
            }
        }
        private void materialLabel1_Click(object sender, EventArgs e)
        {

        }

        private void txtUsuario_TextChanged(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {

        }

        private void label7_Click(object sender, EventArgs e)
        {

        }
    }
}
