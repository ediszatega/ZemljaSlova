using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class OrderItemController : BaseCRUDController<Model.OrderItem, OrderItemSearchObject, OrderItemInsertRequest, OrderItemUpdateRequest>
    {
        public OrderItemController(IOrderItemService service) : base(service) { }
    }
}
