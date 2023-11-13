using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace STR_ADDONPERU_INSTALADOR.EL
{
    public class B1SLLoginResponse
    {
        [JsonProperty(PropertyName = "odata.metadata")]
        public string OdataMetadata { get; set; }
        public string SessionId { get; set; }
        public string Version { get; set; }
        public int SessionTimeout { get; set; }
    }
}
