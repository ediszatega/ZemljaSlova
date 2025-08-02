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
    public interface ITicketTypeTransactionService : ICRUDService<TicketTypeTransaction, TicketTypeTransactionSearchObject, TicketTypeTransactionInsertRequest, TicketTypeTransactionUpdateRequest>
    {
        Task<TicketTypeTransaction> CreateStockTransactionAsync(int ticketTypeId, int quantity, int userId, string? data = null);
        Task<TicketTypeTransaction> CreateSoldTransactionAsync(int ticketTypeId, int quantity, int userId, string? data = null);
        Task<List<TicketTypeTransaction>> GetTransactionsByTicketTypeAsync(int ticketTypeId);
    }
}
