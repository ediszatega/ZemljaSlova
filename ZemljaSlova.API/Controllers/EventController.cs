using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class EventController : BaseCRUDController<Model.Event, EventSearchObject, EventUpsertRequest, EventUpsertRequest>
    {
        public EventController(IEventService service) : base(service) { }
    }
}
