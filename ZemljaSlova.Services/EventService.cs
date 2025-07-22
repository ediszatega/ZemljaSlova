using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class EventService : BaseCRUDService<Model.Event, EventSearchObject, Database.Event, EventUpsertRequest, EventUpsertRequest>, IEventService
    {
        private readonly IMapper _mapper;

        public EventService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
            _mapper = mapper;
        }

        public async Task<Model.Event> GetEventWithTicketTypes(int id)
        {
            var entity = await Context.Events.Include(e => e.TicketTypes).FirstOrDefaultAsync(e => e.Id == id);
            
            if (entity == null)
                return null;
                
            return _mapper.Map<Model.Event>(entity);
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

            return base.AddFilter(search, query);
        }
    }
}
