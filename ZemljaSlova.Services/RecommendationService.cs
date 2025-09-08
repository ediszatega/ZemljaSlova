using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using MathNet.Numerics.LinearAlgebra;
using MathNet.Numerics.LinearAlgebra.Double;

namespace ZemljaSlova.Services
{
    public class RecommendationService : BaseCRUDService<Model.Recommendation, RecommendationSearchObject, Database.Recommendation, RecommendationInsertRequest, RecommendationUpdateRequest>, IRecommendationService
    {
        private readonly _200036Context _context;

        public RecommendationService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        public async Task<List<Database.Recommendation>> GenerateRecommendationsAsync(int memberId)
        {
            var updatedRecommendations = new List<Database.Recommendation>();

            // Clear existing recommendations for this member
            var existingRecommendations = await _context.Recommendations
                .Where(r => r.MemberId == memberId)
                .ToListAsync();

            _context.Recommendations.RemoveRange(existingRecommendations);

            // Generate recommendations
            var collaborativeRecommendations = await GenerateRecommendationsBasedOnSimilarityAsync(memberId);
            var matrixFactorizationRecommendations = await GenerateMatrixFactorizationRecommendationsAsync(memberId);
            var contentBasedRecommendations = await GenerateContentBasedRecommendationsAsync(memberId);

            // Combine recommendations with weighted scoring
            var combinedRecommendations = CombineRecommendationsWithWeights(
                memberId,
                collaborativeRecommendations,
                matrixFactorizationRecommendations,
                contentBasedRecommendations
            );

            // Get member's already purchased books to exclude them
            var purchasedBooks = await GetMemberPurchasedBooksAsync(memberId);
            var favouriteBooks = await GetMemberFavouriteBooksAsync(memberId);
            var uniqueBookIds = new HashSet<int>();

            // Filter and save unique recommendations
            foreach (var recommendation in combinedRecommendations)
            {
                var bookExists = await _context.Books
                    .AnyAsync(book => book.Id == recommendation.BookId && 
                             book.BookPurpose == 1); // Only books for sale

                if (bookExists && 
                    !uniqueBookIds.Contains(recommendation.BookId) && 
                    !purchasedBooks.Contains(recommendation.BookId))
                {
                    uniqueBookIds.Add(recommendation.BookId);
                    _context.Recommendations.Add(recommendation);
                    updatedRecommendations.Add(recommendation);
                }
            }

            await _context.SaveChangesAsync();
            return updatedRecommendations;
        }

        // Method 1: Collaborative Filtering based on User Similarity
        private async Task<List<Database.Recommendation>> GenerateRecommendationsBasedOnSimilarityAsync(int targetMemberId)
        {
            List<Database.Recommendation> recommendations = new List<Database.Recommendation>();

            // Get target member's preferences
            var purchasedBooks = await GetMemberPurchasedBooksAsync(targetMemberId);
            var favouriteBooks = await GetMemberFavouriteBooksAsync(targetMemberId);

            // Find similar members
            List<int> similarMembers = await FindSimilarMembersAsync(targetMemberId, purchasedBooks, favouriteBooks);

            // Generate recommendations from similar members preferences
            foreach (var memberId in similarMembers.Take(10)) // Limit to top 10 similar members
            {
                var purchasedBooksForMember = await GetMemberPurchasedBooksAsync(memberId);
                var favouriteBooksForMember = await GetMemberFavouriteBooksAsync(memberId);

                // Convert to recommendations
                var potentialRecommendations = purchasedBooksForMember
                    .Union(favouriteBooksForMember)
                    .Where(bookId => bookId != 0)
                    .Select(bookId => new Database.Recommendation
                    {
                        MemberId = targetMemberId,
                        BookId = bookId
                    });

                recommendations.AddRange(potentialRecommendations);
            }

            return recommendations;
        }

        // Member similarity calculation using cosine similarity
        private async Task<List<int>> FindSimilarMembersAsync(int targetMemberId, List<int> purchasedBooks, List<int> favouriteBooks)
        {
            Dictionary<int, double> memberSimilarityScores = new Dictionary<int, double>();
            List<Database.Member> allMembers = await _context.Members.ToListAsync();

            foreach (var member in allMembers)
            {
                if (member.Id == targetMemberId) continue;

                double similarityScore = await CalculateMemberSimilarityAsync(member, purchasedBooks, favouriteBooks);
                memberSimilarityScores[member.Id] = similarityScore;
            }

            return memberSimilarityScores
                .Where(x => x.Value > 0.1) // Only consider members with similarity > 0.1
                .OrderByDescending(x => x.Value)
                .Select(x => x.Key)
                .ToList();
        }

        private async Task<double> CalculateMemberSimilarityAsync(Database.Member member, List<int> targetPurchasedBooks, List<int> targetFavouriteBooks)
        {
            var memberPurchasedBooks = await GetMemberPurchasedBooksAsync(member.Id);
            var memberFavouriteBooks = await GetMemberFavouriteBooksAsync(member.Id);

            // Combine preferences for both members
            var targetPreferences = targetPurchasedBooks.Union(targetFavouriteBooks).ToHashSet();
            var memberPreferences = memberPurchasedBooks.Union(memberFavouriteBooks).ToHashSet();

            if (targetPreferences.Count == 0 || memberPreferences.Count == 0)
                return 0.0;

            // Calculate cosine similarity
            var bookIntersection = targetPreferences.Intersect(memberPreferences).Count();
            var magnitude1 = Math.Sqrt(targetPreferences.Count);
            var magnitude2 = Math.Sqrt(memberPreferences.Count);

            double bookSimilarity = 0.0;
            if (magnitude1 > 0 && magnitude2 > 0)
            {
                bookSimilarity = bookIntersection / (magnitude1 * magnitude2);
            }

            // Calculate genre similarity
            double genreSimilarity = await CalculateGenreSimilarityAsync(targetPreferences.ToList(), memberPreferences.ToList());

            // Calculate author similarity
            double authorSimilarity = await CalculateAuthorSimilarityAsync(targetPreferences.ToList(), memberPreferences.ToList());

            // Combine similarities with weights
            return (bookSimilarity * 0.6) + (genreSimilarity * 0.25) + (authorSimilarity * 0.15);
        }

        // Method 2: Matrix Factorization using SVD
        private async Task<List<Database.Recommendation>> GenerateMatrixFactorizationRecommendationsAsync(int targetMemberId)
        {
            var (memberPreferences, bookFeatures) = await PerformSVDAsync(targetMemberId);

            if (!memberPreferences.ContainsKey(targetMemberId))
                return new List<Database.Recommendation>();

            int N = 10; // Number of recommendations
            List<int> recommendedBooks = GetTopNRecommendations(memberPreferences[targetMemberId], bookFeatures, N);

            List<Database.Recommendation> recommendations = new List<Database.Recommendation>();
            foreach (var bookId in recommendedBooks)
            {
                recommendations.Add(new Database.Recommendation
                {
                    MemberId = targetMemberId,
                    BookId = bookId
                });
            }

            return recommendations;
        }

        // SVD Implementation
        private async Task<(Dictionary<int, double[]>, Dictionary<int, double[]>)> PerformSVDAsync(int targetMemberId)
        {
            var memberBookMatrix = await CreateMemberBookMatrixAsync();

            if (memberBookMatrix.Count == 0)
                return (new Dictionary<int, double[]>(), new Dictionary<int, double[]>());

            var allMemberIds = memberBookMatrix.Keys.ToList();
            var allBookIds = memberBookMatrix.Values.SelectMany(dict => dict.Keys).Distinct().ToList();

            int numRows = allMemberIds.Count;
            int numCols = allBookIds.Count;

            // Convert to MathNet matrix
            var doubleMatrix = new double[numRows, numCols];
            
            for (int i = 0; i < numRows; i++)
            {
                var memberId = allMemberIds[i];
                for (int j = 0; j < numCols; j++)
                {
                    var bookId = allBookIds[j];
                    doubleMatrix[i, j] = memberBookMatrix.ContainsKey(memberId) && 
                                        memberBookMatrix[memberId].ContainsKey(bookId) 
                                        ? memberBookMatrix[memberId][bookId] 
                                        : 0.0;
                }
            }

            Matrix<double> matrix = DenseMatrix.OfArray(doubleMatrix);
            var svd = matrix.Svd(true);

            // Use reduced dimensions for efficiency
            int k = Math.Min(10, Math.Min(numRows, numCols));
            Matrix<double> memberPreferences = svd.U.SubMatrix(0, numRows, 0, k);
            Matrix<double> bookFeatures = svd.VT.SubMatrix(0, k, 0, numCols).Transpose();

            var memberPreferencesDict = new Dictionary<int, double[]>();
            var bookFeaturesDict = new Dictionary<int, double[]>();

            for (int i = 0; i < numRows; i++)
            {
                memberPreferencesDict[allMemberIds[i]] = memberPreferences.Row(i).ToArray();
            }

            for (int j = 0; j < numCols; j++)
            {
                bookFeaturesDict[allBookIds[j]] = bookFeatures.Row(j).ToArray();
            }

            return (memberPreferencesDict, bookFeaturesDict);
        }

        private async Task<Dictionary<int, Dictionary<int, double>>> CreateMemberBookMatrixAsync()
        {
            var matrix = new Dictionary<int, Dictionary<int, double>>();

            // Get all member-book interactions
            var purchases = await _context.OrderItems
                .Include(oi => oi.Order)
                .Where(oi => oi.BookId.HasValue && oi.Order.PaymentStatus == "succeeded")
                .Select(oi => new { MemberId = oi.Order.MemberId, BookId = oi.BookId.Value, Quantity = oi.Quantity })
                .ToListAsync();

            var favourites = await _context.Favourites
                .Select(f => new { MemberId = f.MemberId, BookId = f.BookId })
                .ToListAsync();

            // Process purchases (higher weight)
            foreach (var purchase in purchases)
            {
                if (!matrix.ContainsKey(purchase.MemberId))
                    matrix[purchase.MemberId] = new Dictionary<int, double>();

                if (!matrix[purchase.MemberId].ContainsKey(purchase.BookId))
                    matrix[purchase.MemberId][purchase.BookId] = 0;

                matrix[purchase.MemberId][purchase.BookId] += purchase.Quantity * 2.0; // Weight purchases higher
            }

            // Process favourites (lower weight)
            foreach (var favourite in favourites)
            {
                if (!matrix.ContainsKey(favourite.MemberId))
                    matrix[favourite.MemberId] = new Dictionary<int, double>();

                if (!matrix[favourite.MemberId].ContainsKey(favourite.BookId))
                    matrix[favourite.MemberId][favourite.BookId] = 0;

                matrix[favourite.MemberId][favourite.BookId] += 1.0;
            }

            return matrix;
        }

        private List<int> GetTopNRecommendations(double[] memberPreferences, Dictionary<int, double[]> bookFeatures, int N)
        {
            var bookScores = new Dictionary<int, double>();

            foreach (var bookFeature in bookFeatures)
            {
                double score = 0;
                for (int i = 0; i < memberPreferences.Length && i < bookFeature.Value.Length; i++)
                {
                    score += memberPreferences[i] * bookFeature.Value[i];
                }
                bookScores[bookFeature.Key] = score;
            }

            return bookScores
                .OrderByDescending(x => x.Value)
                .Take(N)
                .Select(x => x.Key)
                .ToList();
        }

        // Helper methods for data retrieval
        private async Task<List<int>> GetMemberPurchasedBooksAsync(int memberId)
        {
            return await _context.OrderItems
                .Include(oi => oi.Order)
                .Where(oi => oi.Order.MemberId == memberId && 
                           oi.BookId.HasValue && 
                           oi.Order.PaymentStatus == "succeeded")
                .Select(oi => oi.BookId.Value)
                .Distinct()
                .ToListAsync();
        }

        private async Task<List<int>> GetMemberFavouriteBooksAsync(int memberId)
        {
            return await _context.Favourites
                .Where(f => f.MemberId == memberId)
                .Select(f => f.BookId)
                .ToListAsync();
        }

        // Method 3: Content-based recommendations (genre and author preferences)
        private async Task<List<Database.Recommendation>> GenerateContentBasedRecommendationsAsync(int memberId)
        {
            var recommendations = new List<Database.Recommendation>();

            // Get member's book preferences
            var purchasedBooks = await GetMemberPurchasedBooksAsync(memberId);
            var favouriteBooks = await GetMemberFavouriteBooksAsync(memberId);
            var memberBookPreferences = purchasedBooks.Union(favouriteBooks).ToList();

            if (!memberBookPreferences.Any())
                return recommendations;

            // Get preferred genres and authors
            var preferredGenres = await GetMemberPreferredGenresAsync(memberBookPreferences);
            var preferredAuthors = await GetMemberPreferredAuthorsAsync(memberBookPreferences);

            // Find books with similar genres and authors
            var candidateBooks = await _context.Books
                .Include(b => b.Authors)
                .Where(b => b.BookPurpose == 1)
                .ToListAsync();

            foreach (var book in candidateBooks)
            {
                if (memberBookPreferences.Contains(book.Id))
                    continue; // Skip already purchased/favourite books

                double score = 0.0;

                // Genre matching (weight: 0.6)
                if (!string.IsNullOrEmpty(book.Genre) && preferredGenres.Contains(book.Genre))
                {
                    score += 0.6;
                }

                // Author matching (weight: 0.4)
                var bookAuthorIds = book.Authors.Select(a => a.Id).ToList();
                var authorOverlap = bookAuthorIds.Intersect(preferredAuthors).Count();
                if (authorOverlap > 0)
                {
                    score += 0.4 * (authorOverlap / (double)Math.Max(bookAuthorIds.Count, 1));
                }

                // Only recommend books with some similarity
                if (score > 0.3)
                {
                    recommendations.Add(new Database.Recommendation
                    {
                        MemberId = memberId,
                        BookId = book.Id
                    });
                }
            }

            return recommendations.OrderByDescending(r => CalculateContentScore(r.BookId, preferredGenres, preferredAuthors))
                                 .Take(15).ToList();
        }

        // Calculate genre similarity between two sets of books
        private async Task<double> CalculateGenreSimilarityAsync(List<int> bookIds1, List<int> bookIds2)
        {
            var genres1 = await GetGenresForBooksAsync(bookIds1);
            var genres2 = await GetGenresForBooksAsync(bookIds2);

            if (!genres1.Any() || !genres2.Any())
                return 0.0;

            var intersection = genres1.Intersect(genres2).Count();
            var union = genres1.Union(genres2).Count();

            return union > 0 ? (double)intersection / union : 0.0;
        }

        // Calculate author similarity between two sets of books
        private async Task<double> CalculateAuthorSimilarityAsync(List<int> bookIds1, List<int> bookIds2)
        {
            var authors1 = await GetAuthorsForBooksAsync(bookIds1);
            var authors2 = await GetAuthorsForBooksAsync(bookIds2);

            if (!authors1.Any() || !authors2.Any())
                return 0.0;

            var intersection = authors1.Intersect(authors2).Count();
            var union = authors1.Union(authors2).Count();

            return union > 0 ? (double)intersection / union : 0.0;
        }

        // Combine recommendations from different methods with weighted scoring
        private List<Database.Recommendation> CombineRecommendationsWithWeights(
            int memberId,
            List<Database.Recommendation> collaborativeRecommendations,
            List<Database.Recommendation> matrixFactorizationRecommendations,
            List<Database.Recommendation> contentBasedRecommendations)
        {
            var bookScores = new Dictionary<int, double>();

            // Weight collaborative filtering recommendations (40%)
            foreach (var rec in collaborativeRecommendations)
            {
                if (!bookScores.ContainsKey(rec.BookId))
                    bookScores[rec.BookId] = 0;
                bookScores[rec.BookId] += 0.4;
            }

            // Weight matrix factorization recommendations (35%)
            foreach (var rec in matrixFactorizationRecommendations)
            {
                if (!bookScores.ContainsKey(rec.BookId))
                    bookScores[rec.BookId] = 0;
                bookScores[rec.BookId] += 0.35;
            }

            // Weight content-based recommendations (25%)
            foreach (var rec in contentBasedRecommendations)
            {
                if (!bookScores.ContainsKey(rec.BookId))
                    bookScores[rec.BookId] = 0;
                bookScores[rec.BookId] += 0.25;
            }

            // Return top recommendations sorted by combined score
            return bookScores
                .OrderByDescending(kvp => kvp.Value)
                .Take(20)
                .Select(kvp => new Database.Recommendation
                {
                    MemberId = memberId,
                    BookId = kvp.Key
                })
                .ToList();
        }

        private async Task<List<string>> GetMemberPreferredGenresAsync(List<int> bookIds)
        {
            return await _context.Books
                .Where(b => bookIds.Contains(b.Id) && !string.IsNullOrEmpty(b.Genre))
                .Select(b => b.Genre!)
                .Distinct()
                .ToListAsync();
        }

        private async Task<List<int>> GetMemberPreferredAuthorsAsync(List<int> bookIds)
        {
            return await _context.Books
                .Where(b => bookIds.Contains(b.Id))
                .SelectMany(b => b.Authors.Select(a => a.Id))
                .Distinct()
                .ToListAsync();
        }

        private async Task<List<string>> GetGenresForBooksAsync(List<int> bookIds)
        {
            return await _context.Books
                .Where(b => bookIds.Contains(b.Id) && !string.IsNullOrEmpty(b.Genre))
                .Select(b => b.Genre!)
                .Distinct()
                .ToListAsync();
        }

        private async Task<List<int>> GetAuthorsForBooksAsync(List<int> bookIds)
        {
            return await _context.Books
                .Where(b => bookIds.Contains(b.Id))
                .SelectMany(b => b.Authors.Select(a => a.Id))
                .Distinct()
                .ToListAsync();
        }

        private double CalculateContentScore(int bookId, List<string> preferredGenres, List<int> preferredAuthors)
        {
            return 1.0;
        }

        public override IQueryable<Database.Recommendation> AddFilter(RecommendationSearchObject? search, IQueryable<Database.Recommendation> query)
        {
            if (search?.MemberId != null)
            {
                query = query.Where(x => x.MemberId == search.MemberId);
            }

            if (search?.BookId != null)
            {
                query = query.Where(x => x.BookId == search.BookId);
            }

            return base.AddFilter(search, query);
        }
    }
}
