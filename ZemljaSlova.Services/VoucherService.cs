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
                Code = GenerateVoucherCodeWithTimestamp(request.Value),
                IsUsed = false,
                ExpirationDate = DateTime.Now.AddDays(365), // Changed to 1 year for purchased vouchers
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
                Code = string.IsNullOrWhiteSpace(request.Code) ? GenerateVoucherCodeWithTimestamp(request.Value) : request.Code,
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

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(v => v.Code.ToLower().Contains(search.Name.ToLower()));
            }

            if (search.ExpirationDateFrom.HasValue)
            {
                query = query.Where(v => v.ExpirationDate >= search.ExpirationDateFrom.Value);
            }

            if (search.ExpirationDateTo.HasValue)
            {
                query = query.Where(v => v.ExpirationDate <= search.ExpirationDateTo.Value);
            }

            if (search.MinValue.HasValue)
            {
                query = query.Where(v => v.Value >= search.MinValue.Value);
            }
            if (search.MaxValue.HasValue)
            {
                query = query.Where(v => v.Value <= search.MaxValue.Value);
            }

            if (!string.IsNullOrEmpty(search.VoucherType))
            {
                if (search.VoucherType == "promotional")
                {
                    query = query.Where(v => v.PurchasedByMemberId == null);
                }
                else if (search.VoucherType == "purchased")
                {
                    query = query.Where(v => v.PurchasedByMemberId != null);
                }
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

        public async Task<bool> MarkVoucherAsUsed(int voucherId)
        {
            var voucher = await Context.Vouchers.FindAsync(voucherId);
            if (voucher == null)
            {
                return false;
            }

            if (voucher.IsUsed)
            {
                return false; // Already used
            }

            voucher.IsUsed = true;
            await Context.SaveChangesAsync();
            return true;
        }

        private string GenerateVoucherCodeWithTimestamp(decimal value)
        {
            var timestamp = DateTimeOffset.Now.ToUnixTimeMilliseconds();
            var code = $"{value:0}_{timestamp}";
            
            // Ensure it's unique (in case of simultaneous requests)
            while (Context.Vouchers.Any(v => v.Code == code))
            {
                timestamp = DateTimeOffset.Now.ToUnixTimeMilliseconds();
                code = $"{value:0}_{timestamp}";
            }
            
            return code;
        }
    }
}
