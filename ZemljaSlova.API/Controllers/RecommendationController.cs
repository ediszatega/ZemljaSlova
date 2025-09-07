using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class RecommendationController : BaseCRUDController<Recommendation, RecommendationSearchObject, RecommendationInsertRequest, RecommendationUpdateRequest>
    {
        private readonly IRecommendationService _recommendationService;

        public RecommendationController(IRecommendationService service) : base(service)
        {
            _recommendationService = service;
        }

        [HttpGet("GenerateRecommendations/{memberId}")]
        public async Task<ActionResult<IEnumerable<Recommendation>>> GenerateRecommendationsAsync(int memberId)
        {
            try
            {
                var databaseRecommendations = await _recommendationService.GenerateRecommendationsAsync(memberId);
                
                var modelRecommendations = databaseRecommendations.Select(dbRec => new Recommendation
                {
                    Id = dbRec.Id,
                    MemberId = dbRec.MemberId,
                    BookId = dbRec.BookId
                });
                
                return Ok(modelRecommendations);
            }
            catch (Exception ex)
            {
                return BadRequest("Failed to generate recommendations");
            }
        }
    }
}
