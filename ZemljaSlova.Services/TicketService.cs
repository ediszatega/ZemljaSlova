using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class TicketService : BaseCRUDService<Model.Ticket, TicketSearchObject, Database.Ticket, TicketInsertRequest, TicketUpdateRequest>, ITicketService
    {
        public TicketService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
