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
    public class TicketTypeService : BaseCRUDService<Model.TicketType, TicketTypeSearchObject, Database.TicketType, TicketTypeInsertRequest, TicketTypeUpdateRequest>, ITicketTypeService
    {
        public TicketTypeService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
