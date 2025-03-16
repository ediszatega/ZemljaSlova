using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TicketController : BaseCRUDController<Model.Ticket, TicketSearchObject, TicketInsertRequest, TicketUpdateRequest>
    {
        public TicketController(ITicketService service) : base(service) { }
    }
}
