using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class TicketTypeController : BaseCRUDController<Model.TicketType, TicketTypeSearchObject, TicketTypeInsertRequest, TicketTypeUpdateRequest>
    {
        public TicketTypeController(ITicketTypeService service) : base(service) { }
    }
}
