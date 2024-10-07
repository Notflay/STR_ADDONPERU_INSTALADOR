using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace STR_ADDONPERU_INSTALADOR.Entidad
{
    public class ConsultationResponse<T>
    {
        public string CodRespuesta { get; set; }
        public string DescRespuesta { get; set; }
        public T Result { get; set; }
        public string Token { get; set; }
    }
}
