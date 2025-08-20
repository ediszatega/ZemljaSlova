using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Enums;
using ModelUserBookClubTransaction = ZemljaSlova.Model.UserBookClubTransaction;

namespace ZemljaSlova.Services
{
    public interface IBookClubPointsService
    {
        Task<int> GetOrCreateUserBookClubAsync(int memberId, int year);
        Task AwardPointsAsync(int memberId, ActivityType activityType, int points, int? orderItemId = null, int? bookTransactionId = null);
        Task<int> GetTotalPointsForYearAsync(int memberId, int year);
        Task<int> GetCurrentYearPointsAsync(int memberId);
        Task<List<ModelUserBookClubTransaction>> GetTransactionsForYearAsync(int memberId, int year);
        Task<bool> HasTransactionForOrderItemAsync(int orderItemId, ActivityType activityType);
        Task<bool> HasTransactionForBookTransactionAsync(int bookTransactionId, ActivityType activityType);
        Task<int> GetPointsForBookTransactionAsync(int bookTransactionId);
        Task<int> GetPointsForOrderItemAsync(int orderItemId);
    }
}
