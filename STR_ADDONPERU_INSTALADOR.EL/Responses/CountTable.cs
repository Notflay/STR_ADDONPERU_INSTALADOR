using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace STR_ADDONPERU_INSTALADOR.EL.Responses
{
    public class CountTable
    {
        public int faltantes { get; set; }
        public int validadas { get; set; }
        public int total { get; set; }

        public void Sumar(CountTable otro)
        {
            faltantes += otro.faltantes;
            validadas += otro.validadas;
            total += otro.total;
        }
    }
}
