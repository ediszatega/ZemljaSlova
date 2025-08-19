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
        private readonly IBookService _bookService;
        private readonly ITicketTypeService _ticketTypeService;
        private readonly IMembershipService _membershipService;

        public OrderService(_200036Context context, IMapper mapper, IConfiguration configuration, IVoucherService voucherService, IBookService bookService, ITicketTypeService ticketTypeService, IMembershipService membershipService) : base(context, mapper)
        {
            _configuration = configuration;
            _voucherService = voucherService;
            _bookService = bookService;
            _ticketTypeService = ticketTypeService;
            _membershipService = membershipService;
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
                    else if (itemRequest.BookId.HasValue)
                    {
                        // Get the member to access the userId
                        var member = await Context.Members.FindAsync(order.MemberId);
                        if (member == null)
                        {
                            throw new Exception($"Member not found for ID {order.MemberId}");
                        }
                        
                        // Check current stock before attempting to sell
                        var currentStock = await _bookService.GetCurrentQuantityAsync(itemRequest.BookId.Value);
                        var isAvailable = await _bookService.IsAvailableForPurchaseAsync(itemRequest.BookId.Value, itemRequest.Quantity);
                        
                        if (!isAvailable)
                        {
                            throw new Exception($"Book {itemRequest.BookId.Value} is not available for purchase. Current stock: {currentStock}, Requested: {itemRequest.Quantity}");
                        }
                        
                        // Sell the books (reduce stock)
                        var success = await _bookService.SellBooksAsync(
                            itemRequest.BookId.Value, 
                            itemRequest.Quantity, 
                            member.UserId, 
                            $"Order {order.Id}"
                        );
                        
                        if (!success)
                        {
                            throw new Exception($"Failed to sell books for book ID {itemRequest.BookId.Value}. Current stock: {currentStock}, Requested: {itemRequest.Quantity}");
                        }
                        
                        var orderItem = Mapper.Map<Database.OrderItem>(itemRequest);
                        Context.OrderItems.Add(orderItem);
                    }
                    else if (itemRequest.TicketTypeId.HasValue)
                    {
                        // Get the member to access the userId
                        var member = await Context.Members.FindAsync(order.MemberId);
                        if (member == null)
                        {
                            throw new Exception($"Member not found for ID {order.MemberId}");
                        }
                        
                        // Check current stock before attempting to sell
                        var currentStock = await _ticketTypeService.GetCurrentQuantityAsync(itemRequest.TicketTypeId.Value);
                        var isAvailable = await _ticketTypeService.IsAvailableForPurchaseAsync(itemRequest.TicketTypeId.Value, itemRequest.Quantity);
                        
                        if (!isAvailable)
                        {
                            throw new Exception($"Ticket type {itemRequest.TicketTypeId.Value} is not available for purchase. Current stock: {currentStock}, Requested: {itemRequest.Quantity}");
                        }
                        
                        // Sell the tickets (reduce stock)
                        var success = await _ticketTypeService.SellTicketsAsync(
                            itemRequest.TicketTypeId.Value, 
                            itemRequest.Quantity, 
                            member.UserId, 
                            $"Order {order.Id}"
                        );
                        
                        if (!success)
                        {
                            throw new Exception($"Failed to sell tickets for ticket type ID {itemRequest.TicketTypeId.Value}. Current stock: {currentStock}, Requested: {itemRequest.Quantity}");
                        }
                        
                        var orderItem = Mapper.Map<Database.OrderItem>(itemRequest);
                        Context.OrderItems.Add(orderItem);
                        
                        // Create individual tickets for each purchased ticket
                        var ticketsToCreate = new List<Database.Ticket>();
                        for (int i = 0; i < itemRequest.Quantity; i++)
                        {
                            var ticket = new Database.Ticket
                            {
                                MemberId = order.MemberId,
                                TicketTypeId = itemRequest.TicketTypeId.Value,
                                OrderItemId = 0, // Will be set after OrderItem is saved
                                PurchasedAt = DateTime.Now,
                                IsUsed = false
                            };
                            
                            ticketsToCreate.Add(ticket);
                        }
                        
                        // Save the OrderItem first to get its ID
                        await Context.SaveChangesAsync();
                        
                        // Set the OrderItemId for all tickets and add them
                        foreach (var ticket in ticketsToCreate)
                        {
                            ticket.OrderItemId = orderItem.Id;
                            Context.Tickets.Add(ticket);
                        }
                    }
                    else if (itemRequest.MembershipId.HasValue || (itemRequest.BookId == null && itemRequest.TicketTypeId == null && itemRequest.VoucherId == null))
                    {
                        var membershipRequest = new MembershipInsertRequest
                        {
                            MemberId = order.MemberId,
                            StartDate = DateTime.Now,
                            EndDate = DateTime.Now.AddDays(30)
                        };
                        
                        var membership = _membershipService.CreateMembershipByMember(membershipRequest);
                        
                        var orderItem = new Database.OrderItem
                        {
                            OrderId = order.Id,
                            MembershipId = membership.Id,
                            Quantity = 1,
                            DiscountId = itemRequest.DiscountId
                        };
                        
                        Context.OrderItems.Add(orderItem);
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
