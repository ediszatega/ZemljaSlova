using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    //[Authorize]
    [ApiController]
    [Route("[controller]")]
    public class BookReservationController : BaseCRUDController<Model.BookReservation, BookReservationSearchObject, BookReservationUpsertRequest, BookReservationUpsertRequest>
    {
        private readonly IBookReservationService _reservationService;
        private readonly IBookService _bookService;

        public BookReservationController(IBookReservationService service, IBookService bookService) : base(service) 
        { 
            _reservationService = service;
            _bookService = bookService;
        }

        [HttpPost("reserve")]
        public async Task<ActionResult<BookReservationResponse>> Reserve([FromBody] BookReservationReserveRequest request)
        {
            try
            {
                var result = await _reservationService.ReserveAsync(request.MemberId, request.BookId);

                var response = new BookReservationResponse
                {
                    Id = result.Id,
                    MemberId = result.MemberId,
                    BookId = result.BookId,
                    ReservedAt = result.ReservedAt
                };

                return Ok(response);
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [HttpPost("cancel")]
        public async Task<ActionResult<bool>> Cancel([FromBody] BookReservationCancelRequest request)
        {
            try
            {
                var result = await _reservationService.CancelAsync(request.ReservationId, request.MemberId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [HttpDelete("{reservationId}/cancel/{memberId}")]
        public async Task<ActionResult<bool>> Cancel(int reservationId, int memberId)
        {
            var ok = await _reservationService.CancelAsync(reservationId, memberId);
            return Ok(ok);
        }

        [HttpGet("{reservationId}/position")]
        public async Task<ActionResult<int>> GetPosition(int reservationId)
        {
            var pos = await _reservationService.GetQueuePositionAsync(reservationId);
            return Ok(pos);
        }

        [HttpGet("book/{bookId}/queue")]
        public async Task<ActionResult<List<Model.BookReservation>>> GetQueueForBook(int bookId)
        {
            var queue = await _reservationService.GetQueueForBookAsync(bookId);
            return Ok(queue);
        }

        [HttpGet("health")]
        public ActionResult<string> Health()
        {
            return Ok("BookReservation service is running");
        }
    }
}
