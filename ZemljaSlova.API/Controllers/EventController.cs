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
    public class EventController : BaseCRUDController<Model.Event, EventSearchObject, EventUpsertRequest, EventUpsertRequest>
    {
        private readonly IEventService _eventService;

        public EventController(IEventService service) : base(service) 
        {
            _eventService = service;
        }

        [HttpGet("GetEventWithTicketTypes/{id}")]
        public async Task<IActionResult> GetEventWithTicketTypes([FromRoute] int id)
        {
            var result = await _eventService.GetEventWithTicketTypes(id);
            return Ok(result);
        }
    }
}
