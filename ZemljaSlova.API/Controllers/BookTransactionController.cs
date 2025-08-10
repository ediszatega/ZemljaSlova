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
    public class BookTransactionController : BaseCRUDController<BookTransaction, BookTransactionSearchObject, BookTransactionInsertRequest, BookTransactionUpdateRequest>
    {
        private readonly IBookTransactionService _transactionService;
        private readonly IBookService _bookService;

        public BookTransactionController(IBookTransactionService service, IBookService bookService) : base(service)
        {
            _transactionService = service;
            _bookService = bookService;
        }

        [HttpGet("book/{bookId}/transactions")]
        public async Task<ActionResult<List<BookTransaction>>> GetTransactionsByBook(int bookId)
        {
            var transactions = await _transactionService.GetTransactionsByBookAsync(bookId);
            return Ok(transactions);
        }

        [HttpGet("book/{bookId}/current-quantity")]
        public async Task<ActionResult<int>> GetCurrentQuantity(int bookId)
        {
            var quantity = await _bookService.GetCurrentQuantityAsync(bookId);
            return Ok(quantity);
        }

        [HttpGet("book/{bookId}/physical-stock")]
        public async Task<ActionResult<int>> GetPhysicalStock(int bookId)
        {
            var quantity = await _bookService.GetPhysicalStockAsync(bookId);
            return Ok(quantity);
        }

        [HttpGet("book/{bookId}/currently-rented")]
        public async Task<ActionResult<int>> GetCurrentlyRented(int bookId)
        {
            var quantity = await _bookService.GetCurrentlyRentedQuantityAsync(bookId);
            return Ok(quantity);
        }

        [HttpGet("book/{bookId}/available")]
        public async Task<ActionResult<bool>> IsAvailableForPurchase(int bookId, [FromQuery] int quantity)
        {
            var isAvailable = await _bookService.IsAvailableForPurchaseAsync(bookId, quantity);
            return Ok(isAvailable);
        }

        [HttpGet("book/{bookId}/available-for-rental")]
        public async Task<ActionResult<bool>> IsAvailableForRental(int bookId, [FromQuery] int quantity)
        {
            var isAvailable = await _bookService.IsAvailableForRentalAsync(bookId, quantity);
            return Ok(isAvailable);
        }

        [HttpPost("book/{bookId}/add-stock")]
        public async Task<ActionResult<bool>> AddStock(int bookId, [FromBody] BookAddSellRequest request)
        {
            var success = await _bookService.AddStockAsync(bookId, request.Quantity, request.UserId, request.Data);
            return Ok(success);
        }

        [HttpPost("book/{bookId}/sell")]
        public async Task<ActionResult<bool>> SellBooks(int bookId, [FromBody] BookAddSellRequest request)
        {
            var success = await _bookService.SellBooksAsync(bookId, request.Quantity, request.UserId, request.Data);
            return Ok(success);
        }

        [HttpPost("book/{bookId}/remove")]
        public async Task<ActionResult<bool>> RemoveBooks(int bookId, [FromBody] BookAddSellRequest request)
        {
            var success = await _bookService.RemoveBooksAsync(bookId, request.Quantity, request.UserId, request.Data);
            return Ok(success);
        }

        [HttpPost("book/{bookId}/rent")]
        public async Task<ActionResult<bool>> RentBooks(int bookId, [FromBody] BookAddSellRequest request)
        {
            var success = await _bookService.RentBooksAsync(bookId, request.Quantity, request.UserId, request.Data);
            return Ok(success);
        }

        [HttpPost("book/{bookId}/return")]
        public async Task<ActionResult<bool>> ReturnBooks(int bookId, [FromBody] BookAddSellRequest request)
        {
            var success = await _bookService.ReturnBooksAsync(bookId, request.Quantity, request.UserId, request.Data);
            return Ok(success);
        }

        [HttpGet("active-rentals")]
        public async Task<ActionResult<List<BookTransaction>>> GetActiveRentals()
        {
            var activeRentals = await _transactionService.GetActiveRentalsAsync();
            return Ok(activeRentals);
        }
    }

    // TODO: Move to Models.Requests
    public class BookAddSellRequest
    {
        public int Quantity { get; set; }
        public int UserId { get; set; }
        public string? Data { get; set; }
    }
} 