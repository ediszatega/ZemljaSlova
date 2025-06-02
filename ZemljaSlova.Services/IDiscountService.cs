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
    public interface IDiscountService : ICRUDService<Discount, DiscountSearchObject, DiscountUpsertRequest, DiscountUpsertRequest>
    {
        Task<Discount?> GetDiscountByCode(string code);
        Task<bool> CanUseDiscountCode(string code);
        Task<int> GetDiscountUsageCount(int discountId);
        Task<decimal> CalculateOrderDiscount(List<OrderItem> orderItems, string? discountCode = null);
        Task IncrementDiscountUsage(int discountId);
        Task<List<Book>> GetBooksWithDiscount(int discountId);
        Task<int> RemoveExpiredDiscountsFromBooks();
        Task<List<Discount>> GetExpiredDiscounts();
    }
}
