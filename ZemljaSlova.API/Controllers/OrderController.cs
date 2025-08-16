using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class OrderController : BaseCRUDController<Model.Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        private readonly IOrderService _orderService;

        public OrderController(IOrderService service) : base(service) 
        {
            _orderService = service;
        }

        [HttpPost("create-payment-intent")]
        public async Task<ActionResult<PaymentIntentResponse>> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request)
        {
            try
            {
                var paymentIntent = await _orderService.CreatePaymentIntentAsync(request.Amount, request.Currency);
                return Ok(paymentIntent);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("process-order")]
        public async Task<ActionResult<Model.Order>> ProcessOrder([FromBody] ProcessOrderRequest request)
        {
            try
            {
                var order = await _orderService.ProcessOrderWithPaymentAsync(request.Order, request.OrderItems);
                return Ok(order);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }

    public class ProcessOrderRequest
    {
        public OrderInsertRequest Order { get; set; } = null!;
        public List<OrderItemInsertRequest> OrderItems { get; set; } = new List<OrderItemInsertRequest>();
    }
}
