using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class OrderController : BaseCRUDController<Model.Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        public OrderController(IOrderService service) : base(service) { }
    }
}
