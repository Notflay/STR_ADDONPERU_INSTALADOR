using SAPbouiCOM;
using System;
using System.Xml;

namespace STR_ADDONPERU_INSTALADOR
{
    public class FuncionesUI
    {
        public SAPbobsCOM.Company sboCompany = null;
        public SAPbouiCOM.Application sboApplication = null;


        public bool conectionString()
        {
            try
            {
                SboGuiApi sboGuiApi = new SboGuiApi();
                string sConectionString = "0030002C0030002C00530041005000420044005F00440061007400650076002C0050004C006F006D0056004900490056";
                sboGuiApi.Connect(sConectionString);

                sboApplication = sboGuiApi.GetApplication(-1);
                sboCompany = sboApplication.Company.GetDICompany();

                if (sboCompany.Connected)
                    return true;
                return false;
            }
            catch (Exception)
            {
                return false;
            }
            finally
            {
                sboApplication = null;
            }
        }

        public void sbCreacionCampos(string addon)
        {

        }


        public void sbCreacionObjetos(string addon)
        {
        }
    }
}
