using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model.Enums;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class BookTransactionService : BaseCRUDService<Model.BookTransaction, BookTransactionSearchObject, Database.BookTransaction, BookTransactionInsertRequest, BookTransactionUpdateRequest>, IBookTransactionService
    {
        public BookTransactionService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<Model.BookTransaction> CreateStockTransactionAsync(int bookId, int quantity, int userId, string? data = null)
        {
            var transaction = new Database.BookTransaction
            {
                ActivityTypeId = (byte)ActivityType.Stock,
                BookId = bookId,
                Qantity = quantity,
                CreatedAt = DateTime.UtcNow,
                UserId = userId,
                Data = data
            };

            Context.BookTransactions.Add(transaction);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.BookTransaction>(transaction);
        }

        public async Task<Model.BookTransaction> CreateSoldTransactionAsync(int bookId, int quantity, int userId, string? data = null)
        {
            var transaction = new Database.BookTransaction
            {
                ActivityTypeId = (byte)ActivityType.Sold,
                BookId = bookId,
                Qantity = quantity,
                CreatedAt = DateTime.UtcNow,
                UserId = userId,
                Data = data
            };

            Context.BookTransactions.Add(transaction);
            await Context.SaveChangesAsync();

            return Mapper.Map<Model.BookTransaction>(transaction);
        }

        public async Task<List<Model.BookTransaction>> GetTransactionsByBookAsync(int bookId)
        {
            var transactions = await Context.BookTransactions
                .Where(t => t.BookId == bookId)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            return Mapper.Map<List<Model.BookTransaction>>(transactions);
        }
    }
} 