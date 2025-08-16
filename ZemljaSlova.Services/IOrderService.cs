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
    public interface IOrderService : ICRUDService<Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        Task<PaymentIntentResponse> CreatePaymentIntentAsync(decimal amount, string currency = "bam");
        Task<Model.Order> ProcessOrderWithPaymentAsync(OrderInsertRequest request, List<OrderItemInsertRequest> orderItems);
    }
}
