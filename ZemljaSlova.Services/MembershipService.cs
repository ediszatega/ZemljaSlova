using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using EasyNetQ;
using ZemljaSlova.Model.Messages;
using Microsoft.EntityFrameworkCore;

namespace ZemljaSlova.Services
{
    public class MembershipService : BaseCRUDService<Model.Membership, MembershipSearchObject, Database.Membership, MembershipInsertRequest, MembershipUpdateRequest>, IMembershipService
    {
        public MembershipService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
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

            // AfterInsert(request, entity);

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
                .ThenInclude(m => m.User)
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

        // TODO: Implement event publishing when membership is created
        // private void PublishMembershipCreatedEvent(Database.Membership entity)
        // {
        //     try
        //     {
        //         var bus = RabbitHutch.CreateBus("host=localhost");
        //         var message = new MembershipCreated { Membership = Mapper.Map<Model.Membership>(entity) };
        //         bus.PubSub.Publish(message);
        //     }
        //     catch (Exception ex)
        //     {
        //         Console.WriteLine($"Failed to publish membership created event: {ex.Message}");
        //     }
        // }

        // public override void AfterInsert(MembershipInsertRequest request, Database.Membership entity)
        // {
        //     base.AfterInsert(request, entity);
        //     PublishMembershipCreatedEvent(entity);
        // }
    }
}
