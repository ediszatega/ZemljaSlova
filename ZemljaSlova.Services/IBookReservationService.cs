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
    public interface IBookReservationService : ICRUDService<BookReservation, BookReservationSearchObject, BookReservationUpsertRequest, BookReservationUpsertRequest>
    {
        Task<Model.BookReservation> ReserveAsync(int memberId, int bookId);
        Task<bool> CancelAsync(int reservationId, int memberId);
        Task<int> GetQueuePositionAsync(int reservationId);
        Task<List<Model.BookReservation>> GetQueueForBookAsync(int bookId);
    }
}
