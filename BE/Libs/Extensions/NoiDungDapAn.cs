using Libs.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Libs.Extensions
{
    public static class NoiDungDapAn
    {
        public static string? GetNoiDungDapAn(CauHoi c, char? kyTu)
        {
            return kyTu switch
            {
                'A' => c.LuaChonA,
                'B' => c.LuaChonB,
                'C' => c.LuaChonC,
                'D' => c.LuaChonD,
                _ => null
            };
        }

    }
}
