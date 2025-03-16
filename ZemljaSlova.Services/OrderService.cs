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
    public class OrderService : BaseCRUDService<Model.Order, OrderSearchObject, Database.Order, OrderInsertRequest, OrderUpdateRequest>, IOrderService
    {
        public OrderService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
