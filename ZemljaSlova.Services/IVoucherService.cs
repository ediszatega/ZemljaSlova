using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;

namespace ZemljaSlova.Services
{
    public interface IVoucherService : IService<Voucher, VoucherSearchObject>
    {
        Voucher InsertMemberVoucher(VoucherMemberInsertRequest request);
        Voucher InsertAdminVoucher(VoucherAdminInsertRequest request);
        Task<Voucher> Delete(int id);
        Task<Voucher?> GetVoucherByCode(string code);
    }
}
