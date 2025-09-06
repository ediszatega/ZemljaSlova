using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;

namespace ZemljaSlova.Services
{
    public interface IRecommendationService : ICRUDService<Recommendation, RecommendationSearchObject, RecommendationInsertRequest, RecommendationUpdateRequest>
    {
        Task<List<Database.Recommendation>> GenerateRecommendationsAsync(int memberId);
    }
}
