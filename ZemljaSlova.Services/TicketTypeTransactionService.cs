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
    public class TicketTypeTransactionService : BaseCRUDService<Model.TicketTypeTransaction, TicketTypeTransactionSearchObject, Database.TicketTypeTransaction, TicketTypeTransactionInsertRequest, TicketTypeTransactionUpdateRequest>, ITicketTypeTransactionService
    {
        public TicketTypeTransactionService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<Model.TicketTypeTransaction> CreateStockTransactionAsync(int ticketTypeId, int quantity, int userId, string? data = null)
        {
            var transaction = new Database.TicketTypeTransaction
            {
                ActivityTypeId = (byte)ActivityType.Stock,
                TicketTypeId = ticketTypeId,
                Quantity = quantity,
                CreatedAt = DateTime.Now,
                UserId = userId,
                Data = data
            };

            Context.TicketTypeTransactions.Add(transaction);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.TicketTypeTransaction>(transaction);
        }

        public async Task<Model.TicketTypeTransaction> CreateSoldTransactionAsync(int ticketTypeId, int quantity, int userId, string? data = null)
        {
            var transaction = new Database.TicketTypeTransaction
            {
                ActivityTypeId = (byte)ActivityType.Sold,
                TicketTypeId = ticketTypeId,
                Quantity = quantity,
                CreatedAt = DateTime.Now,
                UserId = userId,
                Data = data
            };

            Context.TicketTypeTransactions.Add(transaction);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.TicketTypeTransaction>(transaction);
        }

        public async Task<List<Model.TicketTypeTransaction>> GetTransactionsByTicketTypeAsync(int ticketTypeId)
        {
            var transactions = await Context.TicketTypeTransactions
                .Where(t => t.TicketTypeId == ticketTypeId)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            return Mapper.Map<List<Model.TicketTypeTransaction>>(transactions);
        }
    }
}
