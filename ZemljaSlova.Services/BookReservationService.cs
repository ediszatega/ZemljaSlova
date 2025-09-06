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
using ZemljaSlova.Model.Messages;
using Microsoft.EntityFrameworkCore;

namespace ZemljaSlova.Services
{
    public class BookReservationService : BaseCRUDService<Model.BookReservation, BookReservationSearchObject, Database.BookReservation, BookReservationUpsertRequest, BookReservationUpsertRequest>, IBookReservationService
    {
        private readonly IBookService _bookService;
        private readonly IRabbitMQProducer _rabbitMQProducer;
        private readonly IMembershipService _membershipService;

        public BookReservationService(_200036Context context, IMapper mapper, IBookService bookService, IRabbitMQProducer rabbitMQProducer, IMembershipService membershipService) : base(context, mapper)
        {
            _bookService = bookService;
            _rabbitMQProducer = rabbitMQProducer;
            _membershipService = membershipService;
        }

        public async Task<Model.BookReservation> ReserveAsync(int memberId, int bookId)
        {
            try
            {
                // Validate member exists
                var member = Context.Members
                    .Include(m => m.User)
                    .FirstOrDefault(m => m.Id == memberId);
                if (member == null)
                {
                    throw new ArgumentException("Member not found");
                }

                // Validate member has active membership
                if (!_membershipService.HasActiveMembership(memberId))
                {
                    throw new InvalidOperationException("Member must have an active membership to reserve books for rent.");
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
                    
                    // Send confirmation email
                    SendReservationConfirmationEmail(member, dbBook, entity);
                    
                    return result;
                }
                catch (UserException mapEx)
                {
                    throw new UserException($"Greška pri mapiranju rezervacije");
                }
            }
            catch (Exception ex)
            {
                throw new UserException($"Greška pri rezervaciji knjige");
            }
        }

        private void SendReservationConfirmationEmail(Database.Member member, Database.Book book, Database.BookReservation reservation)
        {
            try
            {
                if (member?.User != null)
                {
                    var emailModel = new EmailModel
                    {
                        To = member.User.Email,
                        Subject = "Potvrda o rezervaciji knjige - Zemlja Slova",
                        Body = GenerateReservationEmailBody(member.User, book, reservation),
                        From = "zemljaslova@gmail.com"
                    };

                    _rabbitMQProducer.SendMessage(emailModel);
                }
            }
            catch (UserException ex)
            {
                throw new UserException("Greška pri slanju emaila za rezervaciju knjige");
            }
            catch (Exception ex)
            {
                // Log the error but don't fail the reservation
                Console.WriteLine($"Failed to send reservation email: {ex.Message}");
            }
        }

        private string GenerateReservationEmailBody(Database.User user, Database.Book book, Database.BookReservation reservation)
        {
            var reservationDate = reservation.ReservedAt.ToString("dd.MM.yyyy HH:mm");

            return $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
                        <h1 style='color: #2c5aa0; text-align: center;'>Potvrda rezervacije knjige</h1>
                        
                        <p>Poštovani/a <strong>{user.FirstName} {user.LastName}</strong>,</p>
                        
                        <p>Uspješno ste rezervirali knjigu u Zemlja Slova.</p>
                        
                        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;'>
                            <h3 style='color: #2c5aa0; margin-top: 0;'>Detalji rezervacije:</h3>
                            <ul style='list-style: none; padding: 0;'>
                                <li><strong>Knjiga:</strong> {book.Title}</li>
                                <li><strong>Datum rezervacije:</strong> {reservationDate}</li>
                                <li><strong>Status:</strong> <span style='color: #ffc107; font-weight: bold;'>Rezervirano</span></li>
                            </ul>
                        </div>
                        
                        <p><strong>Važne napomene:</strong></p>
                        <ul>
                            <li>Rezervacija je važeća do prve dostupnosti knjige</li>
                            <li>Rezervacija vam daje prednost za iznajmljivanje knjige, ali ne i potpunu sigurnost, u slučaju da niste u mogućnosti da lično preuzmete knjigu u razumnom roku nakon što ona ponovo bude na stanju</li>
                            <li>Možete otkazati rezervaciju u bilo kojem trenutku</li>
                        </ul>
                        
                        <p>Hvala vam što koristite Zemlja Slova!</p>
                        
                        <p style='margin-top: 30px; font-size: 14px; color: #666;'>
                            Srdačan pozdrav,<br>
                            <strong>Tim Zemlja Slova</strong>
                        </p>
                    </div>
                </body>
                </html>";
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
