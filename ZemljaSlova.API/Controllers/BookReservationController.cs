using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BookReservationController : BaseCRUDController<Model.BookReservation, BookReservationSearchObject, BookReservationUpsertRequest, BookReservationUpsertRequest>
    {
        public BookReservationController(IBookReservationService service) : base(service) { }
    }
}
