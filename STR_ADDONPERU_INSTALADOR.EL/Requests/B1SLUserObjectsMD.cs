using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace STR_ADDONPERU_INSTALADOR.EL.Requests
{
    public class B1SLUserObjectsMD
    {
        public string Code { get; set; }
        public string Name { get; set; }
        public string TableName { get; set; }
        public int ObjectType { get; set; }
        public string ManageSeries { get; set; }
        public string CanFind { get; set; }
        public string CanYearTransfer { get; set; }
        public string CanCreateDefaultForm { get; set; }
        public string CanCancel { get; set; }
        public string CanDelete { get; set; }
        public string CanLog { get; set; }
        public List<UserObjectMD_ChildTable> UserObjectMD_ChildTables { get; set; }
        public List<UserObjectMD_FindColumn> UserObjectMD_FindColumns { get; set; }
    }
    public class UserObjectMD_ChildTable
    {
        public string TableName { get; set; }
        public string ObjectName { get; set; }
    }

    public class UserObjectMD_FindColumn
    {
        public string ColumnAlias { get; set; }
        public string ColumnDescription { get; set; }
    }
}
