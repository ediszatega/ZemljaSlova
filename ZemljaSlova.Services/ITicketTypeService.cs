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
    public interface ITicketTypeService : ICRUDService<TicketType, TicketTypeSearchObject, TicketTypeInsertRequest, TicketTypeUpdateRequest>
    {
        Task<int> GetCurrentQuantityAsync(int ticketTypeId);
        Task<bool> IsAvailableForPurchaseAsync(int ticketTypeId, int requestedQuantity);
        Task<bool> AddStockAsync(int ticketTypeId, int quantity, int userId, string? data = null);
        Task<bool> SellTicketsAsync(int ticketTypeId, int quantity, int userId, string? data = null);
    }
}
