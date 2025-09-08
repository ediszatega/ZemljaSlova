using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using ZemljaSlova.Model.Enums;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class EventController : BaseCRUDController<Model.Event, EventSearchObject, EventUpsertRequest, EventUpsertRequest>
    {
        private readonly IEventService _eventService;
        private readonly ITicketTypeService _ticketTypeService;

        public EventController(IEventService service, ITicketTypeService ticketTypeService) : base(service) 
        {
            _eventService = service;
            _ticketTypeService = ticketTypeService;
        }

        [HttpGet("GetEventWithTicketTypes/{id}")]
        public async Task<IActionResult> GetEventWithTicketTypes([FromRoute] int id)
        {
            var result = await _eventService.GetEventWithTicketTypes(id);
            return Ok(result);
        }

        [HttpPost("PurchaseTickets")]
        public async Task<IActionResult> PurchaseTickets([FromBody] PurchaseTicketsRequest request)
        {
            var success = await _ticketTypeService.SellTicketsAsync(
                request.TicketTypeId, 
                request.Quantity, 
                request.UserId, 
                request.Data);

            if (success)
            {
                return Ok(new { success = true, message = "Tickets purchased successfully" });
            }
            else
            {
                return BadRequest(new { success = false, message = "Failed to purchase tickets. Insufficient quantity or invalid request." });
            }
        }

        [HttpGet("{id}/image")]
        [AllowAnonymous]
        public IActionResult GetEventImage(int id)
        {
            try
            {
                var eventEntity = _eventService.GetById(id);
                if (eventEntity?.CoverImage == null || eventEntity.CoverImage.Length == 0)
                {
                    return NotFound("Slika nije pronađena");
                }

                return File(eventEntity.CoverImage, "image/jpeg");
            }
            catch (Exception)
            {
                return StatusCode(500, "Greška prilikom dobavljanja slike");
            }
        }

        [HttpPost("with-image")]
        [Consumes("multipart/form-data")]
        public async Task<Model.Event> CreateEventWithImage()
        {
            return await _eventService.CreateEventFromForm(Request.Form);
        }

        [HttpPut("{id}/with-image")]
        [Consumes("multipart/form-data")]
        public async Task<Model.Event> UpdateEventWithImage(int id)
        {
            return await _eventService.UpdateEventFromForm(id, Request.Form);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = UserRoles.Admin)]
        public override async Task<Model.Event> Delete(int id)
        {
            return await _eventService.Delete(id);
        }
    }

    public class PurchaseTicketsRequest
    {
        public int TicketTypeId { get; set; }
        public int Quantity { get; set; }
        public int UserId { get; set; }
        public string? Data { get; set; }
    }
}
