using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Stripe;
using Stripe.Checkout;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Enums;
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
        private readonly IBookClubPointsService _bookClubPointsService;

        public OrderService(_200036Context context, IMapper mapper, IConfiguration configuration, IVoucherService voucherService, IBookService bookService, ITicketTypeService ticketTypeService, IMembershipService membershipService, IBookClubPointsService bookClubPointsService) : base(context, mapper)
        {
            _configuration = configuration;
            _voucherService = voucherService;
            _bookService = bookService;
            _ticketTypeService = ticketTypeService;
            _membershipService = membershipService;
            _bookClubPointsService = bookClubPointsService;
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
                            await Context.SaveChangesAsync();
                            
                            await _bookClubPointsService.AwardPointsAsync(
                                order.MemberId, 
                                ActivityType.VoucherPurchase, 
                                20, 
                                orderItemId: orderItem.Id
                            );
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
                        await Context.SaveChangesAsync();
                        
                        await _bookClubPointsService.AwardPointsAsync(
                            order.MemberId, 
                            ActivityType.BookPurchase, 
                            30 * itemRequest.Quantity, 
                            orderItemId: orderItem.Id
                        );
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
                        await Context.SaveChangesAsync();
                        
                        // Create individual tickets for each purchased ticket
                        var ticketsToCreate = new List<Database.Ticket>();
                        for (int i = 0; i < itemRequest.Quantity; i++)
                        {
                            var ticket = new Database.Ticket
                            {
                                MemberId = order.MemberId,
                                TicketTypeId = itemRequest.TicketTypeId.Value,
                                OrderItemId = orderItem.Id,
                                PurchasedAt = DateTime.Now,
                                IsUsed = false
                            };
                            
                            ticketsToCreate.Add(ticket);
                        }
                        
                        // Add all tickets
                        foreach (var ticket in ticketsToCreate)
                        {
                            Context.Tickets.Add(ticket);
                        }
                        
                        await _bookClubPointsService.AwardPointsAsync(
                            order.MemberId, 
                            ActivityType.EventTicketPurchase, 
                            20 * itemRequest.Quantity, 
                            orderItemId: orderItem.Id
                        );
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
                        await Context.SaveChangesAsync();
                        
                        await _bookClubPointsService.AwardPointsAsync(
                            order.MemberId, 
                            ActivityType.MembershipPayment, 
                            50, 
                            orderItemId: orderItem.Id
                        );
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

        public async Task<PagedResult<Model.Order>> GetMemberTransactionsAsync(string email, int page, int pageSize, string? transactionType)
        {
            try
            {
                // Get member by email
                var member = Context.Members
                    .Include(m => m.User)
                    .FirstOrDefault(m => m.User.Email == email);

                if (member == null)
                {
                    throw new Exception("Member not found");
                }

                var query = Context.Orders
                    .Where(o => o.MemberId == member.Id);

                // Apply transaction type filter
                if (!string.IsNullOrEmpty(transactionType) && transactionType.ToLower() != "all")
                {
                    switch (transactionType.ToLower())
                    {
                        case "vouchers":
                            query = query.Where(o => o.OrderItems.Any(oi => oi.VoucherId != null));
                            break;
                        case "books":
                            query = query.Where(o => o.OrderItems.Any(oi => oi.BookId != null));
                            break;
                        case "tickets":
                            query = query.Where(o => o.OrderItems.Any(oi => oi.TicketTypeId != null));
                            break;
                        case "memberships":
                            query = query.Where(o => o.OrderItems.Any(oi => oi.MembershipId != null));
                            break;
                    }
                }
                else
                {
                    query = query.Where(o => o.OrderItems.Any());
                }

                var totalCount = await query.CountAsync();

                var orders = await query
                    .OrderByDescending(o => o.PurchasedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                var orderDtos = Mapper.Map<List<Model.Order>>(orders);

                return new PagedResult<Model.Order>
                {
                    ResultList = orderDtos,
                    Count = totalCount
                };
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to get member transactions: {ex.Message}");
            }
        }

        public async Task<List<Model.OrderItem>> GetOrderItemsByOrderIdAsync(int orderId)
        {
            try
            {
                var orderItems = await Context.OrderItems
                    .Include(oi => oi.Book)
                        .ThenInclude(b => b.Authors)
                    .Include(oi => oi.Voucher)
                    .Include(oi => oi.TicketType)
                        .ThenInclude(tt => tt.Event)
                    .Include(oi => oi.Membership)
                    .Where(oi => oi.OrderId == orderId)
                    .ToListAsync();

                var result = Mapper.Map<List<Model.OrderItem>>(orderItems);

                // Get points earned for each order item
                foreach (var orderItem in result)
                {
                    orderItem.PointsEarned = await _bookClubPointsService.GetPointsForOrderItemAsync(orderItem.Id);
                }

                return result;
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to get order items: {ex.Message}");
            }
        }
    }
}
