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
        private readonly IVoucherService _voucherService;

        public OrderService(_200036Context context, IMapper mapper, IConfiguration configuration, IVoucherService voucherService) : base(context, mapper)
        {
            _configuration = configuration;
            _voucherService = voucherService;
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
                // Retrieve the payment intent if provided to verify it was successful
                if (!string.IsNullOrEmpty(request.PaymentIntentId))
                {
                    var paymentIntentService = new PaymentIntentService();
                    var paymentIntent = await paymentIntentService.GetAsync(request.PaymentIntentId);

                    if (paymentIntent.Status != "succeeded")
                    {
                        throw new Exception($"Payment failed: {paymentIntent.Status}");
                    }

                    // Update payment info
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
                    
                    // Create new vouchers when purchasing
                    if (itemRequest.VoucherId.HasValue)
                    {
                        var voucherValue = itemRequest.VoucherId.Value;
                        
                        for (int i = 0; i < itemRequest.Quantity; i++)
                        {
                            var voucherRequest = new VoucherMemberInsertRequest
                            {
                                Value = voucherValue,
                                MemberId = order.MemberId
                            };
                            
                            var newVoucher = _voucherService.InsertMemberVoucher(voucherRequest);
                            
                            var orderItem = new Database.OrderItem
                            {
                                OrderId = order.Id,
                                VoucherId = newVoucher.Id,
                                Quantity = 1, // Each voucher is individual
                                DiscountId = itemRequest.DiscountId
                            };
                            
                            Context.OrderItems.Add(orderItem);
                        }
                    }
                    else
                    {
                        var orderItem = Mapper.Map<Database.OrderItem>(itemRequest);
                        Context.OrderItems.Add(orderItem);
                    }
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
