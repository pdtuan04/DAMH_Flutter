using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Libs.Models
{
    public class KetQuaBaiThiDto
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;

        public Guid BaiThiId { get; set; }

        public List<CauTraLoiDto> KetQuaList { get; set; } = new List<CauTraLoiDto>();
        public int SoCauDung { get; set; }
        public int TongSoCau { get; set; }
        public int TongDiem { get; set; }
        public string KetQua { get; set; } = string.Empty;
        public bool MacLoiNghiemTrong { get; set; }
        public int SoCauLoiNghiemTrong { get; set; }
    }
}
