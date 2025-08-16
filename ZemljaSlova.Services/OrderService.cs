using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.Extensions.Configuration;
using Stripe;
using Stripe.Checkout;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class OrderService : BaseCRUDService<Model.Order, OrderSearchObject, Database.Order, OrderInsertRequest, OrderUpdateRequest>, IOrderService
    {
        private readonly IConfiguration _configuration;

        public OrderService(_200036Context context, IMapper mapper, IConfiguration configuration) : base(context, mapper)
        {
            _configuration = configuration;
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(decimal amount, string currency = "bam")
        {
            try
            {
                var options = new PaymentIntentCreateOptions
                {
                    Amount = (long)(amount * 100), // Convert to cents
                    Currency = currency,
                    AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                    {
                        Enabled = true,
                    },
                };

                var service = new PaymentIntentService();
                var paymentIntent = await service.CreateAsync(options);

                return new PaymentIntentResponse
                {
                    ClientSecret = paymentIntent.ClientSecret,
                    PaymentIntentId = paymentIntent.Id,
                    Amount = amount,
                    Currency = currency,
                    Status = paymentIntent.Status
                };
            }
            catch (StripeException ex)
            {
                throw new Exception($"Stripe error: {ex.Message}");
            }
        }

        public async Task<Model.Order> ProcessOrderWithPaymentAsync(OrderInsertRequest request, List<OrderItemInsertRequest> orderItems)
        {
            try
            {
                // Confirm the payment intent if provided
                if (!string.IsNullOrEmpty(request.PaymentMethodId))
                {
                    var paymentIntentService = new PaymentIntentService();
                    var paymentIntent = await paymentIntentService.ConfirmAsync(request.PaymentMethodId);

                    if (paymentIntent.Status != "succeeded")
                    {
                        throw new Exception($"Payment failed: {paymentIntent.Status}");
                    }

                    // Update payment info
                    request.PaymentIntentId = paymentIntent.Id;
                    request.PaymentStatus = paymentIntent.Status;
                }

                // Create the order
                var order = Mapper.Map<Database.Order>(request);
                order.PurchasedAt = DateTime.Now;
                
                Context.Orders.Add(order);
                await Context.SaveChangesAsync();

                // Create order items
                foreach (var itemRequest in orderItems)
                {
                    itemRequest.OrderId = order.Id;
                    var orderItem = Mapper.Map<Database.OrderItem>(itemRequest);
                    Context.OrderItems.Add(orderItem);
                }

                await Context.SaveChangesAsync();

                return Mapper.Map<Model.Order>(order);
            }
            catch (Exception ex)
            {
                throw new Exception($"Order processing failed: {ex.Message}");
            }
        }
    }
}
