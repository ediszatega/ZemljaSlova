using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model.Enums;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class TicketTypeService : BaseCRUDService<Model.TicketType, TicketTypeSearchObject, Database.TicketType, TicketTypeInsertRequest, TicketTypeUpdateRequest>, ITicketTypeService
    {
        private readonly ITicketTypeTransactionService _transactionService;

        public TicketTypeService(_200036Context context, IMapper mapper, ITicketTypeTransactionService transactionService) : base(context, mapper)
        {
            _transactionService = transactionService;
        }

        public override Model.TicketType Insert(TicketTypeInsertRequest request)
        {
            var result = base.Insert(request);
            
            // If initial quantity is specified, create a stock transaction
            if (request.InitialQuantity.HasValue && request.InitialQuantity.Value > 0)
            {
                // Get the created ticket type ID
                var ticketType = Context.TicketTypes
                    .Where(t => t.EventId == request.EventId && t.Name == request.Name)
                    .OrderByDescending(t => t.Id)
                    .FirstOrDefault();
                
                if (ticketType != null)
                {
                    var userExists = Context.Users.Any(u => u.Id == request.UserId);
                    if (!userExists)
                    {
                        throw new InvalidOperationException($"User with ID {request.UserId} does not exist in database");
                    }
                    
                    _transactionService.CreateStockTransactionAsync(
                        ticketType.Id, 
                        request.InitialQuantity.Value, 
                        request.UserId.Value,
                        "Inicijalna količina"
                    ).GetAwaiter().GetResult();
                }
            }
            
            return result;
        }

        public async Task<int> GetCurrentQuantityAsync(int ticketTypeId)
        {
            var transactions = await Context.TicketTypeTransactions
                .Where(t => t.TicketTypeId == ticketTypeId)
                .ToListAsync();

            int currentQuantity = 0;

            foreach (var transaction in transactions)
            {
                if (transaction.ActivityTypeId == (byte)ActivityType.Stock)
                {
                    currentQuantity += transaction.Quantity;
                }
                else if (transaction.ActivityTypeId == (byte)ActivityType.Sold)
                {
                    currentQuantity -= transaction.Quantity;
                }
            }

            return currentQuantity;
        }

        public async Task<bool> IsAvailableForPurchaseAsync(int ticketTypeId, int requestedQuantity)
        {
            if (requestedQuantity <= 0)
                return false;

            var currentQuantity = await GetCurrentQuantityAsync(ticketTypeId);
            return currentQuantity >= requestedQuantity;
        }

        public async Task<bool> AddStockAsync(int ticketTypeId, int quantity, int userId, string? data = null)
        {
            if (quantity <= 0)
            {
                return false;
            }

            var userExists = await Context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return false;
            }

            try
            {
                await _transactionService.CreateStockTransactionAsync(ticketTypeId, quantity, userId, data);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public async Task<bool> SellTicketsAsync(int ticketTypeId, int quantity, int userId, string? data = null)
        {
            if (quantity <= 0)
            {
                return false;
            }

            var userExists = await Context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return false;
            }

            // Check if we have enough tickets
            if (!await IsAvailableForPurchaseAsync(ticketTypeId, quantity))
            {
                return false;
            }

            try
            {
                await _transactionService.CreateSoldTransactionAsync(ticketTypeId, quantity, userId, data);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
