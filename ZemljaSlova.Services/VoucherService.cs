using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace ZemljaSlova.Services
{
    public class VoucherService : BaseService<Model.Voucher, VoucherSearchObject, Database.Voucher>, IVoucherService
    {
        public VoucherService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public Model.Voucher InsertMemberVoucher(VoucherMemberInsertRequest request)
        {
            var entity = new Database.Voucher
            {
                Value = request.Value,
                Code = GenerateUniqueVoucherCode(),
                IsUsed = false,
                ExpirationDate = DateTime.Now.AddDays(60), 
                PurchasedByMemberId = request.MemberId,
                PurchasedAt = DateTime.Now
            };

            Context.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Model.Voucher>(entity);
        }

        public Model.Voucher InsertAdminVoucher(VoucherAdminInsertRequest request)
        {
            var entity = new Database.Voucher
            {
                Value = request.Value,
                Code = string.IsNullOrWhiteSpace(request.Code) ? GenerateUniqueVoucherCode() : request.Code,
                IsUsed = false,
                ExpirationDate = request.ExpirationDate,
                PurchasedByMemberId = null, // Admin created - no member
                PurchasedAt = DateTime.Now // Creation date for admin vouchers
            };

            Context.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Model.Voucher>(entity);
        }

        public async Task<Model.Voucher> Delete(int id)
        {
            var entity = await Context.Vouchers.FindAsync(id);
            if (entity == null)
            {
                throw new ArgumentException("Voucher not found");
            }

            if (entity.PurchasedByMemberId.HasValue)
            {
                throw new InvalidOperationException("Cannot delete purchased vouchers. Only employee-created promotional vouchers can be deleted.");
            }

            if (entity.IsUsed)
            {
                throw new InvalidOperationException("Cannot delete used vouchers.");
            }

            var voucherModel = Mapper.Map<Model.Voucher>(entity);
            
            Context.Vouchers.Remove(entity);
            await Context.SaveChangesAsync();
            
            return voucherModel;
        }

        public override IQueryable<Database.Voucher> AddFilter(VoucherSearchObject search, IQueryable<Database.Voucher> query)
        {
            query = query.Include(v => v.PurchasedByMember)
                         .ThenInclude(m => m.User);

            if (search.MemberId.HasValue)
            {
                query = query.Where(v => v.PurchasedByMemberId == search.MemberId.Value);
            }

            if (search.IsUsed.HasValue)
            {
                query = query.Where(v => v.IsUsed == search.IsUsed.Value);
            }

            if (!string.IsNullOrEmpty(search.Code))
            {
                query = query.Where(v => v.Code.Contains(search.Code));
            }

            if (search.ExpirationDateFrom.HasValue)
            {
                query = query.Where(v => v.ExpirationDate >= search.ExpirationDateFrom.Value);
            }

            if (search.ExpirationDateTo.HasValue)
            {
                query = query.Where(v => v.ExpirationDate <= search.ExpirationDateTo.Value);
            }

            return base.AddFilter(search, query);
        }

        public override Model.Voucher GetById(int id)
        {
            var entity = Context.Vouchers
                .Include(v => v.PurchasedByMember)
                .ThenInclude(m => m.User)
                .FirstOrDefault(v => v.Id == id);
                
            if (entity == null)
            {
                return null;
            }
            
            return Mapper.Map<Model.Voucher>(entity);
        }

        public async Task<Model.Voucher?> GetVoucherByCode(string code)
        {
            var voucher = await Context.Vouchers
                .Include(v => v.PurchasedByMember)
                .ThenInclude(m => m.User)
                .FirstOrDefaultAsync(v => v.Code == code);

            return voucher != null ? Mapper.Map<Model.Voucher>(voucher) : null;
        }

        private string GenerateUniqueVoucherCode()
        {
            string code;
            bool exists;

            do
            {
                code = GenerateVoucherCode();
                exists = Context.Vouchers.Any(v => v.Code == code);
            } 
            while (exists);

            return code;
        }

        private string GenerateVoucherCode()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            var random = new Random();
            
            return new string(Enumerable.Repeat(chars, 8)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        }
    }
}
