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
    public class TicketTypeTransactionService : BaseCRUDService<Model.TicketTypeTransaction, TicketTypeTransactionSearchObject, Database.TicketTypeTransaction, TicketTypeTransactionInsertRequest, TicketTypeTransactionUpdateRequest>, ITicketTypeTransactionService
    {
        public TicketTypeTransactionService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
