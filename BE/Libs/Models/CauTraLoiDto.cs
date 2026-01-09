using Libs.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Libs.Models
{
    public class CauTraLoiDto
    {
        public string DapAnDung { get; set; } = string.Empty;
        public string UserDapAn { get; set; } = string.Empty;
        public Guid BaiThiId { get; set; }
        public Guid CauHoiId { get; set; }
        public CauHoi CauHoi { get; set; }
        public bool DungSai { get; set; }
    }
}
