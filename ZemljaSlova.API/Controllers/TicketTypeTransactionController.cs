using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    //[Authorize]
    [ApiController]
    [Route("[controller]")]
    public class TicketTypeTransactionController : BaseCRUDController<TicketTypeTransaction, TicketTypeTransactionSearchObject, TicketTypeTransactionInsertRequest, TicketTypeTransactionUpdateRequest>
    {
        private readonly ITicketTypeTransactionService _transactionService;
        private readonly ITicketTypeService _ticketTypeService;

        public TicketTypeTransactionController(ITicketTypeTransactionService service, ITicketTypeService ticketTypeService) : base(service)
        {
            _transactionService = service;
            _ticketTypeService = ticketTypeService;
        }

        [HttpGet("ticket-type/{ticketTypeId}/transactions")]
        public async Task<ActionResult<List<TicketTypeTransaction>>> GetTransactionsByTicketType(int ticketTypeId)
        {
            var transactions = await _transactionService.GetTransactionsByTicketTypeAsync(ticketTypeId);
            return Ok(transactions);
        }

        [HttpGet("ticket-type/{ticketTypeId}/current-quantity")]
        public async Task<ActionResult<int>> GetCurrentQuantity(int ticketTypeId)
        {
            var quantity = await _ticketTypeService.GetCurrentQuantityAsync(ticketTypeId);
            return Ok(quantity);
        }

        [HttpGet("ticket-type/{ticketTypeId}/available")]
        public async Task<ActionResult<bool>> IsAvailableForPurchase(int ticketTypeId, [FromQuery] int quantity)
        {
            var isAvailable = await _ticketTypeService.IsAvailableForPurchaseAsync(ticketTypeId, quantity);
            return Ok(isAvailable);
        }

        [HttpPost("ticket-type/{ticketTypeId}/add-stock")]
        public async Task<ActionResult<bool>> AddStock(int ticketTypeId, [FromBody] TicketsAddSellRequest request)
        {
            var success = await _ticketTypeService.AddStockAsync(ticketTypeId, request.Quantity, request.UserId, request.Data);
            return Ok(success);
        }

        [HttpPost("ticket-type/{ticketTypeId}/sell")]
        public async Task<ActionResult<bool>> SellTickets(int ticketTypeId, [FromBody] TicketsAddSellRequest request)
        {
            var success = await _ticketTypeService.SellTicketsAsync(ticketTypeId, request.Quantity, request.UserId, request.Data);
            return Ok(success);
        }
    }

    public class TicketsAddSellRequest
    {
        public int Quantity { get; set; }
        public int UserId { get; set; }
        public string? Data { get; set; }
    }

}
