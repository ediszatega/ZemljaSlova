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
    public class MembershipService : BaseCRUDService<Model.Membership, MembershipSearchObject, Database.Membership, MembershipInsertRequest, MembershipUpdateRequest>, IMembershipService
    {
        private readonly IRabbitMQProducer _rabbitMQProducer;
        private readonly IBookClubPointsService _bookClubPointsService;

        public MembershipService(_200036Context context, IMapper mapper, IRabbitMQProducer rabbitMQProducer, IBookClubPointsService bookClubPointsService) : base(context, mapper)
        {
            _rabbitMQProducer = rabbitMQProducer;
            _bookClubPointsService = bookClubPointsService;
        }

        public override IQueryable<Database.Membership> AddFilter(MembershipSearchObject search, IQueryable<Database.Membership> query)
        {
            if (search.IncludeMember == true)
            {
                query = query.Include(m => m.Member).ThenInclude(m => m.User);
            }

            if (search.IsActive.HasValue)
            {
                var now = DateTime.Now;
                if (search.IsActive.Value)
                {
                    query = query.Where(m => m.StartDate <= now && m.EndDate >= now);
                }
                else
                {
                    query = query.Where(m => m.StartDate > now || m.EndDate < now);
                }
            }

            if (search.IsExpired.HasValue)
            {
                var now = DateTime.Now;
                if (search.IsExpired.Value)
                {
                    query = query.Where(m => m.EndDate < now);
                }
                else
                {
                    query = query.Where(m => m.EndDate >= now);
                }
            }

            if (search.StartDateFrom.HasValue)
            {
                query = query.Where(m => m.StartDate >= search.StartDateFrom.Value);
            }

            if (search.StartDateTo.HasValue)
            {
                query = query.Where(m => m.StartDate <= search.StartDateTo.Value);
            }

            if (search.EndDateFrom.HasValue)
            {
                query = query.Where(m => m.EndDate >= search.EndDateFrom.Value);
            }

            if (search.EndDateTo.HasValue)
            {
                query = query.Where(m => m.EndDate <= search.EndDateTo.Value);
            }

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(m => m.Member.User.FirstName.ToLower().Contains(search.Name.ToLower()) || m.Member.User.LastName.ToLower().Contains(search.Name.ToLower()));
            }

            return base.AddFilter(search, query);
        }

        public override Model.Membership Insert(MembershipInsertRequest request)
        {
            if (HasActiveMembership(request.MemberId))
            {
                throw new InvalidOperationException("Member already has an active membership. Cannot create a new membership while one is active.");
            }

            var startDate = request.StartDate == default(DateTime) ? DateTime.Now.Date : request.StartDate;
            var endDate = request.EndDate == default(DateTime) ? startDate.AddDays(30) : request.EndDate;

            var entity = new Database.Membership
            {
                MemberId = request.MemberId,
                StartDate = startDate,
                EndDate = endDate
            };

            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();

            AfterInsert(request, entity);

            return Mapper.Map<Model.Membership>(entity);
        }

        public Model.Membership CreateMembershipByMember(MembershipInsertRequest request)
        {
            if (HasActiveMembership(request.MemberId))
            {
                throw new InvalidOperationException("Member already has an active membership. Cannot create a new membership while one is active.");
            }
            // members cannot set start or end date - always starts today and lasts 30 days
            request.StartDate = default(DateTime);
            request.EndDate = default(DateTime);

            return Insert(request);
        }

        public async Task<Model.Membership> CreateMembershipByEmployeeAsync(MembershipInsertRequest request)
        {
            if (HasActiveMembership(request.MemberId))
            {
                throw new InvalidOperationException("Member already has an active membership. Cannot create a new membership while one is active.");
            }

            var startDate = request.StartDate == default(DateTime) ? DateTime.Now.Date : request.StartDate;
            var endDate = request.EndDate == default(DateTime) ? startDate.AddDays(30) : request.EndDate;

            var entity = new Database.Membership
            {
                MemberId = request.MemberId,
                StartDate = startDate,
                EndDate = endDate
            };

            BeforeInsert(request, entity);

            Context.Add(entity);
            await Context.SaveChangesAsync();

            // Create transaction record for employee-created membership
            await CreateMembershipTransactionAsync(entity);

            AfterInsert(request, entity);

            return Mapper.Map<Model.Membership>(entity);
        }

        private async Task CreateMembershipTransactionAsync(Database.Membership membership)
        {
            // Create an order to track the membership transaction
            var order = new Database.Order
            {
                MemberId = membership.MemberId,
                Amount = 15,
                PurchasedAt = DateTime.Now,
                PaymentStatus = "completed",
                PaymentIntentId = $"employee_membership_{membership.Id}_{DateTime.Now:yyyyMMddHHmmss}"
            };

            Context.Orders.Add(order);
            await Context.SaveChangesAsync();

            // Create order item for the membership
            var orderItem = new Database.OrderItem
            {
                OrderId = order.Id,
                MembershipId = membership.Id,
                Quantity = 1
            };

            Context.OrderItems.Add(orderItem);
            await Context.SaveChangesAsync();

            // Award book club points for membership
            await _bookClubPointsService.AwardPointsAsync(
                membership.MemberId,
                Model.Enums.ActivityType.MembershipPayment,
                50,
                orderItemId: orderItem.Id
            );
        }

        public Model.Membership GetActiveMembership(int memberId)
        {
            var now = DateTime.Now;
            var activeMembership = Context.Memberships
                .Include(m => m.Member)
                .ThenInclude(m => m.User)
                .FirstOrDefault(m => m.MemberId == memberId && 
                                   m.StartDate <= now && 
                                   m.EndDate >= now);

            return activeMembership != null ? Mapper.Map<Model.Membership>(activeMembership) : null;
        }

        public List<Model.Membership> GetMemberMemberships(int memberId)
        {
            var memberships = Context.Memberships
                .Include(m => m.Member)
                .Where(m => m.MemberId == memberId)
                .OrderByDescending(m => m.StartDate)
                .ToList();

            return Mapper.Map<List<Model.Membership>>(memberships);
        }

        public bool HasActiveMembership(int memberId)
        {
            var now = DateTime.Now;
            return Context.Memberships.Any(m => m.MemberId == memberId && 
                                              m.StartDate <= now && 
                                              m.EndDate >= now);
        }

        public override void BeforeDelete(Database.Membership entity)
        {
            // Clean up related order items
            var relatedOrderItems = Context.OrderItems
                .Where(oi => oi.MembershipId == entity.Id)
                .ToList();
            
            if (relatedOrderItems.Any())
            {
                Context.OrderItems.RemoveRange(relatedOrderItems);
            }
            
            // Remove related notifications
            if (entity.Notifications != null && entity.Notifications.Any())
            {
                Context.Notifications.RemoveRange(entity.Notifications);
            }
        }

        private void PublishMembershipCreatedEvent(Database.Membership entity)
        {
            try
            {
                var memberWithUser = Context.Members
                    .Include(m => m.User)
                    .FirstOrDefault(m => m.Id == entity.MemberId);

                if (memberWithUser?.User != null)
                {
                    var emailModel = new EmailModel
                    {
                        To = memberWithUser.User.Email,
                        Subject = "Dobrodošli u Zemlju Slova!",
                        Body = GenerateMembershipEmailBody(memberWithUser.User, entity),
                        From = "zemljaslova@gmail.com"
                    };

                    _rabbitMQProducer.SendMessage(emailModel);
                }
            }
            catch (UserException ex)
            {
                throw new UserException("Greška pri slanju emaila za članarinu");
            }
            catch (Exception ex)
            {
                // Log the error but don't fail the membership creation
                Console.WriteLine($"Failed to send membership email: {ex.Message}");
            }
        }

        private string GenerateMembershipEmailBody(Database.User user, Database.Membership membership)
        {
            var startDate = membership.StartDate.ToString("dd.MM.yyyy");
            var endDate = membership.EndDate.ToString("dd.MM.yyyy");

            return $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
                        <h1 style='color: #2c5aa0; text-align: center;'>Dobrodošli u Zemlju Slova!</h1>
                        
                        <p>Poštovani/a <strong>{user.FirstName} {user.LastName}</strong>,</p>
                        
                        <p>Čestitamo! Uspješno ste platili vašu članarinu.</p>
                        
                        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;'>
                            <h3 style='color: #2c5aa0; margin-top: 0;'>Detalji članarine:</h3>
                            <ul style='list-style: none; padding: 0;'>
                                <li><strong>Datum početka:</strong> {startDate}</li>
                                <li><strong>Datum završetka:</strong> {endDate}</li>
                                <li><strong>Status:</strong> <span style='color: #28a745; font-weight: bold;'>Aktivno</span></li>
                            </ul>
                        </div>
                        
                        <p>Kao član/ica Zemlja Slova, možete:</p>
                        <ul>
                            <li>Iznajmljivati knjige</li>
                            <li>Rezervirati knjige za iznajmljivanje</li>
                            <li>Sakupljati bodove za Klub čitalaca</li>
                            <li>Koristiti posebne popuste</li>
                        </ul>
                        
                        <p>Hvala vam što ste odabrali Zemlju Slova!</p>
                        
                        <p style='margin-top: 30px; font-size: 14px; color: #666;'>
                            Srdačan pozdrav,<br>
                            <strong>Tim Zemlja Slova</strong>
                        </p>
                    </div>
                </body>
                </html>";
        }

        public override void AfterInsert(MembershipInsertRequest request, Database.Membership entity)
        {
            base.AfterInsert(request, entity);
            PublishMembershipCreatedEvent(entity);
        }
    }
}
