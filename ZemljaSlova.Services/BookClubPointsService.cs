using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Enums;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Services.Database;
using DatabaseUserBookClubTransaction = ZemljaSlova.Services.Database.UserBookClubTransaction;
using ModelUserBookClubTransaction = ZemljaSlova.Model.UserBookClubTransaction;

namespace ZemljaSlova.Services
{
    public class BookClubPointsService : IBookClubPointsService
    {
        private readonly _200036Context _context;
        private readonly IMapper _mapper;

        public BookClubPointsService(_200036Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<int> GetOrCreateUserBookClubAsync(int memberId, int year)
        {
            // Check if UserBookClub record exists for this member and year
            var existingRecord = await _context.UserBookClubs
                .FirstOrDefaultAsync(ubc => ubc.MemberId == memberId && ubc.Year == year);

            if (existingRecord != null)
            {
                return existingRecord.Id;
            }

            // Create new UserBookClub record
            var newRecord = new Database.UserBookClub
            {
                MemberId = memberId,
                Year = year
            };

            _context.UserBookClubs.Add(newRecord);
            await _context.SaveChangesAsync();

            return newRecord.Id;
        }

        public async Task AwardPointsAsync(int memberId, ActivityType activityType, int points, int? orderItemId = null, int? bookTransactionId = null)
        {
            var currentYear = DateTime.Now.Year;
            var userBookClubId = await GetOrCreateUserBookClubAsync(memberId, currentYear);

            // Check if transaction already exists to prevent duplicates
            bool transactionExists = false;
            if (orderItemId.HasValue)
            {
                transactionExists = await HasTransactionForOrderItemAsync(orderItemId.Value, activityType);
            }
            else if (bookTransactionId.HasValue)
            {
                transactionExists = await HasTransactionForBookTransactionAsync(bookTransactionId.Value, activityType);
            }

            if (transactionExists)
            {
                return; // Points already awarded for this transaction
            }

            // Create new transaction record
            var transaction = new DatabaseUserBookClubTransaction
            {
                ActivityTypeId = (byte)activityType,
                UserBookClubId = userBookClubId,
                Points = points,
                CreatedAt = DateTime.Now,
                OrderItemId = orderItemId,
                BookTransactionId = bookTransactionId
            };

            _context.UserBookClubTransactions.Add(transaction);
            await _context.SaveChangesAsync();
        }

        public async Task<int> GetTotalPointsForYearAsync(int memberId, int year)
        {
            // Ensure UserBookClub record exists for this member and year
            var userBookClubId = await GetOrCreateUserBookClubAsync(memberId, year);
            
            // Calculate total points by summing all transactions for this UserBookClub
            var totalPoints = await _context.UserBookClubTransactions
                .Where(ubct => ubct.UserBookClubId == userBookClubId)
                .SumAsync(ubct => ubct.Points);

            return totalPoints;
        }

        public async Task<int> GetCurrentYearPointsAsync(int memberId)
        {
            var currentYear = DateTime.Now.Year;
            
            // Ensure UserBookClub record exists for current year
            var userBookClubId = await GetOrCreateUserBookClubAsync(memberId, currentYear);
            
            // Calculate total points by summing all transactions for this UserBookClub
            var totalPoints = await _context.UserBookClubTransactions
                .Where(ubct => ubct.UserBookClubId == userBookClubId)
                .SumAsync(ubct => ubct.Points);

            return totalPoints;
        }

        public async Task<List<ModelUserBookClubTransaction>> GetTransactionsForYearAsync(int memberId, int year)
        {
            // Ensure UserBookClub record exists for this member and year
            var userBookClubId = await GetOrCreateUserBookClubAsync(memberId, year);
            
            // Get all transactions for this UserBookClub with related data
            var transactions = await _context.UserBookClubTransactions
                .Include(ubct => ubct.OrderItem)
                .Include(ubct => ubct.BookTransaction)
                .Where(ubct => ubct.UserBookClubId == userBookClubId)
                .OrderByDescending(ubct => ubct.CreatedAt)
                .ToListAsync();

            return _mapper.Map<List<ModelUserBookClubTransaction>>(transactions);
        }

        public async Task<bool> HasTransactionForOrderItemAsync(int orderItemId, ActivityType activityType)
        {
            return await _context.UserBookClubTransactions
                .AnyAsync(ubct => ubct.OrderItemId == orderItemId && ubct.ActivityTypeId == (byte)activityType);
        }

        public async Task<bool> HasTransactionForBookTransactionAsync(int bookTransactionId, ActivityType activityType)
        {
            return await _context.UserBookClubTransactions
                .AnyAsync(ubct => ubct.BookTransactionId == bookTransactionId && ubct.ActivityTypeId == (byte)activityType);
        }

        public async Task<int> GetPointsForBookTransactionAsync(int bookTransactionId)
        {
            var transaction = await _context.UserBookClubTransactions
                .FirstOrDefaultAsync(ubct => ubct.BookTransactionId == bookTransactionId);
            
            return transaction?.Points ?? 0;
        }

        public async Task<int> GetPointsForOrderItemAsync(int orderItemId)
        {
            var transaction = await _context.UserBookClubTransactions
                .FirstOrDefaultAsync(ubct => ubct.OrderItemId == orderItemId);
            
            return transaction?.Points ?? 0;
        }

        public async Task<object> GetLeaderboardAsync(int year, int page, int pageSize)
        {
            var skip = (page - 1) * pageSize;

            // Get all members with their points for the specified year
            var memberPoints = await (
                from m in _context.Members
                join u in _context.Users on m.UserId equals u.Id
                join ubc in _context.UserBookClubs on m.Id equals ubc.MemberId into ubcJoin
                from ubc in ubcJoin.DefaultIfEmpty()
                join ubct in _context.UserBookClubTransactions on ubc.Id equals ubct.UserBookClubId into ubctJoin
                from ubct in ubctJoin.DefaultIfEmpty()
                where ubc == null || ubc.Year == year
                group new { m, u, ubct } by new { m.Id, u.FirstName, u.LastName, u.Email } into g
                select new
                {
                    MemberId = g.Key.Id,
                    MemberName = $"{g.Key.FirstName} {g.Key.LastName}",
                    Email = g.Key.Email,
                    Points = g.Where(x => x.ubct != null).Sum(x => x.ubct.Points)
                }
            ).ToListAsync();

            // Order by points descending and add rank
            var rankedMembers = memberPoints
                .OrderByDescending(mp => mp.Points)
                .ThenBy(mp => mp.MemberName)
                .Skip(skip)
                .Take(pageSize)
                .Select((mp, index) => new
                {
                    Rank = skip + index + 1,
                    mp.MemberId,
                    mp.MemberName,
                    mp.Email,
                    mp.Points
                })
                .ToList();

            return new
            {
                Members = rankedMembers,
                TotalCount = memberPoints.Count()
            };
        }
    }
}
