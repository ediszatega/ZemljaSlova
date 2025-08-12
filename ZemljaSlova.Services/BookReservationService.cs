using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class BookReservationService : BaseCRUDService<Model.BookReservation, BookReservationSearchObject, Database.BookReservation, BookReservationUpsertRequest, BookReservationUpsertRequest>, IBookReservationService
    {
        private readonly IBookService _bookService;

        public BookReservationService(_200036Context context, IMapper mapper, IBookService bookService) : base(context, mapper)
        {
            _bookService = bookService;
        }

        public async Task<Model.BookReservation> ReserveAsync(int memberId, int bookId)
        {
            try
            {
                // Validate member exists
                var member = Context.Members.FirstOrDefault(m => m.Id == memberId);
                if (member == null)
                {
                    throw new ArgumentException("Member not found");
                }

                // Validate book exists and is rental type
                var dbBook = Context.Books.FirstOrDefault(b => b.Id == bookId);
                if (dbBook == null)
                {
                    throw new ArgumentException("Book not found");
                }
                if (dbBook.BookPurpose != (int)BookPurpose.Rent)
                {
                    throw new InvalidOperationException("Reservations are only allowed for books intended for rent.");
                }

                // Ensure no available copies right now and book has physical copies
                try
                {
                    var physicalStock = await _bookService.GetPhysicalStockAsync(bookId);
                    
                    if (physicalStock <= 0)
                    {
                        throw new InvalidOperationException("Cannot reserve books with no physical copies.");
                    }
                    
                    var currentlyRented = await _bookService.GetCurrentlyRentedQuantityAsync(bookId);
                    
                    var availableCopies = Math.Max(0, physicalStock - currentlyRented);
                    
                    if (availableCopies > 0)
                    {
                        throw new InvalidOperationException("Reservation not allowed while copies are available for rent.");
                    }
                }
                catch (Exception stockEx)
                {
                    throw new InvalidOperationException($"Failed to check book availability: {stockEx.Message}");
                }

                // Prevent duplicate active reservation for same member and book
                var alreadyReserved = Context.BookReservations
                    .Any(r => r.BookId == bookId && r.MemberId == memberId);
                if (alreadyReserved)
                {
                    throw new InvalidOperationException("Member already has a reservation for this book.");
                }

                var entity = new Database.BookReservation
                {
                    BookId = bookId,
                    MemberId = memberId,
                    ReservedAt = DateTime.UtcNow
                };

                try
                {
                    Context.BookReservations.Add(entity);
                    await Context.SaveChangesAsync();
                }
                catch (Exception dbEx)
                {
                    throw new InvalidOperationException($"Failed to save reservation to database: {dbEx.Message}");
                }

                try
                {
                    var result = Mapper.Map<Model.BookReservation>(entity);
                    return result;
                }
                catch (Exception mapEx)
                {
                    throw new InvalidOperationException($"Failed to map reservation: {mapEx.Message}");
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public async Task<bool> CancelAsync(int reservationId, int memberId)
        {
            var reservation = await Context.BookReservations.FindAsync(reservationId);
            if (reservation == null)
            {
                return false;
            }
            if (reservation.MemberId != memberId)
            {
                throw new InvalidOperationException("Only the member who created the reservation can cancel it.");
            }

            Context.BookReservations.Remove(reservation);
            await Context.SaveChangesAsync();
            return true;
        }

        public Task<int> GetQueuePositionAsync(int reservationId)
        {
            var reservation = Context.BookReservations.FirstOrDefault(r => r.Id == reservationId);
            if (reservation == null)
            {
                throw new ArgumentException("Reservation not found");
            }

            var ordered = Context.BookReservations
                .Where(r => r.BookId == reservation.BookId)
                .OrderBy(r => r.ReservedAt)
                .ThenBy(r => r.Id)
                .ToList();

            var index = ordered.FindIndex(r => r.Id == reservationId);
            if (index < 0)
            {
                throw new ArgumentException("Reservation not found in queue");
            }
            return Task.FromResult(index + 1);
        }

        public Task<List<Model.BookReservation>> GetQueueForBookAsync(int bookId)
        {
            var queue = Context.BookReservations
                .Where(r => r.BookId == bookId)
                .OrderBy(r => r.ReservedAt)
                .ThenBy(r => r.Id)
                .ToList();

            var mapped = Mapper.Map<List<Model.BookReservation>>(queue);
            return Task.FromResult(mapped);
        }
    }
}
