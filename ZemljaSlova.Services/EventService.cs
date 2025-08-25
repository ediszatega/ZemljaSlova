using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class EventService : BaseCRUDService<Model.Event, EventSearchObject, Database.Event, EventUpsertRequest, EventUpsertRequest>, IEventService
    {
        private readonly IMapper _mapper;
        private readonly ITicketTypeService _ticketTypeService;

        public EventService(_200036Context context, IMapper mapper, ITicketTypeService ticketTypeService) : base(context, mapper)
        {
            _mapper = mapper;
            _ticketTypeService = ticketTypeService;
        }

        public async Task<Model.Event> GetEventWithTicketTypes(int id)
        {
            var entity = await Context.Events.Include(e => e.TicketTypes).FirstOrDefaultAsync(e => e.Id == id);
            
            if (entity == null)
                return null;
                
            var eventModel = _mapper.Map<Model.Event>(entity);
            
            // Calculate current quantities for each ticket type
            foreach (var ticketType in eventModel.TicketTypes)
            {
                ticketType.CurrentQuantity = await _ticketTypeService.GetCurrentQuantityAsync(ticketType.Id);
            }
            
            return eventModel;
        }

        public override IQueryable<Database.Event> AddFilter(EventSearchObject search, IQueryable<Database.Event> query)
        {
            if (search.IsTicketTypeIncluded == true)
            {
                query = query.Include("TicketTypes");
            }

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(e => e.Title.ToLower().Contains(search.Name.ToLower()));
            }

            // Filter out events that have already ended (show only current and future events)
            // Unless ShowPastEvents is explicitly set to true
            if (!search.ShowPastEvents.HasValue || !search.ShowPastEvents.Value)
            {
                var today = DateTime.Today;
                query = query.Where(e => e.StartAt >= today);
            }

            // Price range filters
            if (search.MinPrice.HasValue)
            {
                query = query.Where(e => e.TicketTypes.Any(t => t.Price >= search.MinPrice.Value));
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(e => e.TicketTypes.Any(t => t.Price <= search.MaxPrice.Value));
            }

            // Date range filters
            if (search.StartDateFrom.HasValue)
            {
                query = query.Where(e => e.StartAt >= search.StartDateFrom.Value);
            }

            if (search.StartDateTo.HasValue)
            {
                query = query.Where(e => e.StartAt <= search.StartDateTo.Value);
            }

            // Apply sorting
            if (!string.IsNullOrEmpty(search.SortBy))
            {
                switch (search.SortBy.ToLower())
                {
                    case "title":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(e => e.Title)
                            : query.OrderBy(e => e.Title);
                        break;
                    case "price":
                        // For price sorting, we need to join with ticket types and get min/max price
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(e => e.TicketTypes.Max(t => t.Price))
                            : query.OrderBy(e => e.TicketTypes.Min(t => t.Price));
                        break;
                    case "date":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(e => e.StartAt)
                            : query.OrderBy(e => e.StartAt);
                        break;
                    default:
                        query = query.OrderByDescending(e => e.StartAt);
                        break;
                }
            }
            else
            {
                query = query.OrderByDescending(e => e.StartAt);
            }

            return base.AddFilter(search, query);
        }

        public override void BeforeDelete(Database.Event entity)
        {
            // Check if event has sold tickets
            var hasSoldTickets = Context.TicketTypeTransactions
                .Any(ttt => ttt.TicketType.EventId == entity.Id);
            
            if (hasSoldTickets)
            {
                throw new UserException("Nije moguće izbrisati događaj koji ima prodane karte.");
            }
        }
    }
}
