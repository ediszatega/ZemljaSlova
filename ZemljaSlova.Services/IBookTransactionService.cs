using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;

namespace ZemljaSlova.Services
{
    public interface IBookTransactionService : ICRUDService<BookTransaction, BookTransactionSearchObject, BookTransactionInsertRequest, BookTransactionUpdateRequest>
    {
        Task<BookTransaction> CreateStockTransactionAsync(int bookId, int quantity, int userId, string? data = null);
        Task<BookTransaction> CreateSoldTransactionAsync(int bookId, int quantity, int userId, string? data = null);
        Task<List<BookTransaction>> GetTransactionsByBookAsync(int bookId);
    }
} 