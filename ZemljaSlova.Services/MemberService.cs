using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Services.Utils;

namespace ZemljaSlova.Services
{
    public class MemberService : BaseCRUDService<Model.Member, MemberSearchObject, Database.Member, MemberInsertRequest, MemberUpdateRequest>, IMemberService
    {
        private readonly _200036Context _context;
        private readonly IMapper _mapper;
        private readonly IUserService _userService;

        public MemberService(_200036Context context, IMapper mapper, IUserService userService) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
            _userService = userService;
        }

        public override IQueryable<Database.Member> AddFilter(MemberSearchObject search, IQueryable<Database.Member> query)
        {
            if (search.IsUserIncluded == true)
            {
                query = query.Include("User");
            }
            
            // Always include Memberships for active/inactive filtering
            query = query.Include("Memberships");

            // Filter by name (firstName or lastName)
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(m => m.User.FirstName.ToLower().Contains(search.Name.ToLower()) || m.User.LastName.ToLower().Contains(search.Name.ToLower()));
            }

            if (!string.IsNullOrEmpty(search.Gender))
            {
                query = query.Where(m => m.User.Gender == search.Gender);
            }

            if (search.BirthYearFrom.HasValue)
            {
                query = query.Where(m => m.DateOfBirth.Year >= search.BirthYearFrom.Value);
            }
            if (search.BirthYearTo.HasValue)
            {
                query = query.Where(m => m.DateOfBirth.Year <= search.BirthYearTo.Value);
            }

            if (search.JoinedYearFrom.HasValue)
            {
                query = query.Where(m => m.JoinedAt.Year >= search.JoinedYearFrom.Value);
            }
            if (search.JoinedYearTo.HasValue)
            {
                query = query.Where(m => m.JoinedAt.Year <= search.JoinedYearTo.Value);
            }

            // Filter by active/inactive members
            // By default, show only active members unless ShowInactiveMembers is explicitly set to true
            if (!search.ShowInactiveMembers.HasValue || !search.ShowInactiveMembers.Value)
            {
                var today = DateTime.Today;
                query = query.Where(m => m.Memberships.Any(ms => ms.EndDate >= today));
            }

            if (!string.IsNullOrEmpty(search.SortBy))
            {
                switch (search.SortBy.ToLower())
                {
                    case "name":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(m => m.User.FirstName + " " + m.User.LastName)
                            : query.OrderBy(m => m.User.FirstName + " " + m.User.LastName);
                        break;
                    default:
                        query = query.OrderBy(m => m.User.FirstName + " " + m.User.LastName);
                        break;
                }
            }
            else
            {
                query = query.OrderBy(m => m.User.FirstName + " " + m.User.LastName);
            }

            return base.AddFilter(search, query);
        }

        public override Model.Member GetById(int id)
        {
            var entity = _context.Members
                .Include(m => m.User)
                .FirstOrDefault(m => m.Id == id);

            if (entity == null)
            {
                return null;
            }

            return _mapper.Map<Model.Member>(entity);
        }

        public async Task<Model.Member> CreateMember(MemberInsertRequest request)
        {
            Database.Member member;
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    var user = new UserInsertRequest
                    {
                        FirstName = request.FirstName,
                        LastName = request.LastName,
                        Email = request.Email,
                        Gender = request.Gender,
                    };

                    // Validate password requirements
                    if (!PasswordValidator.IsValidPassword(request.Password))
                    {
                        throw new Exception(PasswordValidator.GetPasswordRequirementsMessage());
                    }
                    
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.Password);
                    user.Password = hashedPassword;
                    Model.User createdUser = _userService.Insert(user);
                    await _context.SaveChangesAsync();

                    member = new Database.Member
                    {
                        UserId = createdUser.Id,
                        DateOfBirth = request.DateOfBirth,
                        JoinedAt = request.JoinedAt
                    };

                    _context.Members.Add(member);
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return _mapper.Map<Model.Member>(member);
        }

        public async Task<Model.Member> UpdateMember(int id, MemberUpdateRequest request)
        {
            Database.Member member;
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    // First, get the member with its User
                    member = await _context.Members
                        .Include(m => m.User)
                        .FirstOrDefaultAsync(m => m.Id == id);

                    if (member == null)
                    {
                        throw new Exception("Member not found");
                    }

                    var userUpdateRequest = new UserUpdateRequest
                    {
                        FirstName = request.FirstName,
                        LastName = request.LastName,
                        Gender = request.Gender,
                        Email = request.Email
                    };

                    _mapper.Map(userUpdateRequest, member.User);

                    member.DateOfBirth = request.DateOfBirth;
                    
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return _mapper.Map<Model.Member>(member);
        }

        public List<Model.Favourite> GetMemberFavourites(int memberId)
        {
            var favourites = _context.Favourites
                .Include(f => f.Book)
                .Where(f => f.MemberId == memberId)
                .ToList();

            return _mapper.Map<List<Model.Favourite>>(favourites);
        }

        public Model.Member GetByUserId(int userId)
        {
            var entity = _context.Members
                .Include(m => m.User)
                .FirstOrDefault(m => m.UserId == userId);

            if (entity == null) return null;

            return _mapper.Map<Model.Member>(entity);
        }
        
        public override async Task<Model.Member> Delete(int id)
        {
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    // Get the member with all related data
                    var member = await _context.Members
                        .Include(m => m.User)
                            .ThenInclude(u => u.Notifications)
                        .Include(m => m.User)
                            .ThenInclude(u => u.BookTransactions)
                                .ThenInclude(bt => bt.UserBookClubTransactions)
                        .Include(m => m.User)
                            .ThenInclude(u => u.TicketTypeTransactions)
                        .Include(m => m.BookReservations)
                            .ThenInclude(br => br.Notifications)
                        .Include(m => m.Orders)
                            .ThenInclude(o => o.Notifications)
                        .Include(m => m.Orders)
                            .ThenInclude(o => o.OrderItems)
                                .ThenInclude(oi => oi.Tickets)
                        .Include(m => m.Tickets)
                        .Include(m => m.UserBookClubs)
                            .ThenInclude(ubc => ubc.UserBookClubTransactions)
                        .Include(m => m.Favourites)
                        .Include(m => m.Memberships)
                            .ThenInclude(ms => ms.Notifications)
                        .Include(m => m.Memberships)
                            .ThenInclude(ms => ms.OrderItems)
                        .Include(m => m.Vouchers)
                        .FirstOrDefaultAsync(m => m.Id == id);

                    if (member == null)
                    {
                        return null;
                    }

                    var memberModel = _mapper.Map<Model.Member>(member);

                    // Remove all related entities
                    
                    // Remove book reservations and their notifications
                    foreach (var reservation in member.BookReservations)
                    {
                        _context.Notifications.RemoveRange(reservation.Notifications);
                    }
                    _context.BookReservations.RemoveRange(member.BookReservations);
                    
                    // Remove orders, their notifications, order items and tickets
                    foreach (var order in member.Orders)
                    {
                        _context.Notifications.RemoveRange(order.Notifications);
                        
                        foreach (var orderItem in order.OrderItems)
                        {
                            _context.Tickets.RemoveRange(orderItem.Tickets);
                        }
                        
                        _context.OrderItems.RemoveRange(order.OrderItems);
                    }
                    _context.Orders.RemoveRange(member.Orders);
                    
                    // Remove tickets
                    _context.Tickets.RemoveRange(member.Tickets);
                    
                    // Remove user book clubs and their transactions
                    foreach (var userBookClub in member.UserBookClubs)
                    {
                        _context.UserBookClubTransactions.RemoveRange(userBookClub.UserBookClubTransactions);
                    }
                    _context.UserBookClubs.RemoveRange(member.UserBookClubs);
                    
                    // Remove favourites
                    _context.Favourites.RemoveRange(member.Favourites);
                    
                    // Remove memberships, their notifications and order items
                    foreach (var membership in member.Memberships)
                    {
                        _context.Notifications.RemoveRange(membership.Notifications);
                        _context.OrderItems.RemoveRange(membership.OrderItems);
                    }
                    _context.Memberships.RemoveRange(member.Memberships);
                    
                    // Remove vouchers
                    _context.Vouchers.RemoveRange(member.Vouchers);
                    
                    // Remove user notifications
                    _context.Notifications.RemoveRange(member.User.Notifications);
                    
                    // Remove user book transactions and their related user book club transactions
                    foreach (var bookTransaction in member.User.BookTransactions)
                    {
                        _context.UserBookClubTransactions.RemoveRange(bookTransaction.UserBookClubTransactions);
                    }
                    _context.BookTransactions.RemoveRange(member.User.BookTransactions);
                    
                    // Remove user ticket type transactions
                    _context.TicketTypeTransactions.RemoveRange(member.User.TicketTypeTransactions);
                    
                    // Remove the member and user
                    _context.Members.Remove(member);
                    _context.Users.Remove(member.User);
                    
                    await _context.SaveChangesAsync();                
                    transaction.Commit();
    
                    return memberModel;
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    // Log the specific error for debugging
                    Console.WriteLine($"Error deleting member {id}: {ex.Message}");
                    Console.WriteLine($"Stack trace: {ex.StackTrace}");
                    throw new Exception($"Failed to delete member: {ex.Message}", ex);
                }
            }
        }
        

    }
}
