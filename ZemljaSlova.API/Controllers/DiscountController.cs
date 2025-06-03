using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    //[Authorize]
    [ApiController]
    [Route("[controller]")]
    public class DiscountController : BaseCRUDController<Model.Discount, DiscountSearchObject, DiscountInsertRequest, DiscountUpdateRequest>
    {
        private readonly IDiscountService _discountService;

        public DiscountController(IDiscountService service) : base(service) 
        {
            _discountService = service;
        }

        [HttpGet("get_discount_by_code/{code}")]
        public async Task<ActionResult<Model.Discount>> GetDiscountByCode(string code)
        {
            try
            {
                var discount = await _discountService.GetDiscountByCode(code);
                if (discount == null)
                {
                    return NotFound("Discount code not found");
                }
                return Ok(discount);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving the discount.");
            }
        }

        [HttpPost("validate_discount_code/{code}")]
        public async Task<ActionResult<bool>> ValidateDiscountCode(string code)
        {
            try
            {
                var isValid = await _discountService.CanUseDiscountCode(code);
                return Ok(isValid);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while validating the discount code.");
            }
        }

        [HttpPost("calculate_order_discount")]
        public async Task<ActionResult<decimal>> CalculateOrderDiscount([FromBody] Model.Requests.OrderDiscountRequest request)
        {
            try
            {
                var totalDiscount = await _discountService.CalculateOrderDiscount(request.OrderItems, request.DiscountCode);
                return Ok(totalDiscount);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while calculating order discount.");
            }
        }

        [HttpGet("get_discount_usage/{id}")]
        //[Authorize(Roles = "Admin,Employee")] // Only admin/employee should see usage statistics
        public async Task<ActionResult<int>> GetDiscountUsage(int id)
        {
            try
            {
                var usageCount = await _discountService.GetDiscountUsageCount(id);
                return Ok(usageCount);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving usage count.");
            }
        }

        [HttpGet("get_books_with_discount/{id}")]
        public async Task<ActionResult<List<Model.Book>>> GetBooksWithDiscount(int id)
        {
            try
            {
                var books = await _discountService.GetBooksWithDiscount(id);
                return Ok(books);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving books with discount.");
            }
        }

        [HttpPost("cleanup_expired_discounts")]
        //[Authorize(Roles = "Admin,Employee")] // Only admin/employee should be able to trigger cleanup
        public async Task<ActionResult<string>> CleanupExpiredDiscounts()
        {
            try
            {
                var removedCount = await _discountService.RemoveExpiredDiscountsFromBooks();
                return Ok($"Successfully removed expired discounts from {removedCount} books.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while cleaning up expired discounts.");
            }
        }

        [HttpGet("get_expired_discounts")]
        //[Authorize(Roles = "Admin,Employee")] // Only admin/employee should see expired discounts
        public async Task<ActionResult<List<Model.Discount>>> GetExpiredDiscounts()
        {
            try
            {
                var expiredDiscounts = await _discountService.GetExpiredDiscounts();
                return Ok(expiredDiscounts);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving expired discounts.");
            }
        }
    }
}
