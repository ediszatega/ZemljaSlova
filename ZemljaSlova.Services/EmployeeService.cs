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
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Services.Utils;

namespace ZemljaSlova.Services
{
    public class EmployeeService : BaseCRUDService<Model.Employee, EmployeeSearchObject, Database.Employee, EmployeeInsertRequest, EmployeeUpdateRequest>, IEmployeeService
    {
        private readonly _200036Context _context;
        private readonly IMapper _mapper;
        private readonly IUserService _userService;

        public EmployeeService(_200036Context context, IMapper mapper, IUserService userService) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
            _userService = userService;
        }

        public override IQueryable<Database.Employee> AddFilter(EmployeeSearchObject search, IQueryable<Database.Employee> query)
        {
            if (search.IsUserIncluded == true)
            {
                query = query.Include("User");
            }

            // Filter by name (firstName or lastName)
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(e => e.User.FirstName.ToLower().Contains(search.Name.ToLower()) || e.User.LastName.ToLower().Contains(search.Name.ToLower()));
            }

            if (!string.IsNullOrEmpty(search.SortBy))
            {
                switch (search.SortBy.ToLower())
                {
                    case "name":
                        query = search.SortOrder?.ToLower() == "desc" 
                            ? query.OrderByDescending(e => e.User.FirstName + " " + e.User.LastName)
                            : query.OrderBy(e => e.User.FirstName + " " + e.User.LastName);
                        break;
                    default:
                        query = query.OrderBy(e => e.User.FirstName + " " + e.User.LastName);
                        break;
                }
            }
            else
            {
                query = query.OrderBy(e => e.User.FirstName + " " + e.User.LastName);
            }

            return base.AddFilter(search, query);
        }

        public async Task<Model.Employee> CreateEmployee(EmployeeInsertRequest request)
        {
            Database.Employee employee;
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

                    employee = new Database.Employee
                    {
                        UserId = createdUser.Id,
                        AccessLevel = request.AccessLevel
                    };

                    _context.Employees.Add(employee);
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return _mapper.Map<Model.Employee>(employee);
        }
        
        public async Task<Model.Employee> UpdateEmployee(int id, EmployeeUpdateRequest request)
        {
            Database.Employee employee;
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    employee = await _context.Employees
                        .Include(e => e.User)
                        .FirstOrDefaultAsync(e => e.Id == id);

                    if (employee == null)
                    {
                        throw new Exception("Employee not found");
                    }

                    var userUpdateRequest = new UserUpdateRequest
                    {
                        FirstName = request.FirstName,
                        LastName = request.LastName,
                        Gender = request.Gender,
                        Email = request.Email
                    };

                    _mapper.Map(userUpdateRequest, employee.User);
                    
                    employee.AccessLevel = request.AccessLevel;
                    
                    await _context.SaveChangesAsync();
                    transaction.Commit();
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }

            return _mapper.Map<Model.Employee>(employee);
        }

        public override Model.Employee GetById(int id)
        {
            var entity = _context.Employees
                .Include(e => e.User)
                .FirstOrDefault(e => e.Id == id);

            if (entity == null) return null;

            return _mapper.Map<Model.Employee>(entity);
        }
        
        public Model.Employee GetByUserId(int userId)
        {
            var entity = _context.Employees
                .Include(e => e.User)
                .FirstOrDefault(e => e.UserId == userId);

            if (entity == null) return null;

            return _mapper.Map<Model.Employee>(entity);
        }
        
        public override async Task<Model.Employee> Delete(int id)
        {
            using (var transaction = _context.Database.BeginTransaction())
            {
                try
                {
                    // Get the employee with all related data
                    var employee = await _context.Employees
                        .Include(e => e.User)
                            .ThenInclude(u => u.Notifications)
                        .Include(e => e.User)
                            .ThenInclude(u => u.BookTransactions)
                                .ThenInclude(bt => bt.UserBookClubTransactions)
                        .Include(e => e.User)
                            .ThenInclude(u => u.TicketTypeTransactions)
                        .FirstOrDefaultAsync(e => e.Id == id);

                    if (employee == null)
                    {
                        return null;
                    }

                    var employeeModel = _mapper.Map<Model.Employee>(employee);

                    // Remove all related entities
                    
                    // Remove user notifications
                    _context.Notifications.RemoveRange(employee.User.Notifications);
                    
                    // Remove user book transactions and their related user book club transactions
                    foreach (var bookTransaction in employee.User.BookTransactions)
                    {
                        _context.UserBookClubTransactions.RemoveRange(bookTransaction.UserBookClubTransactions);
                    }
                    _context.BookTransactions.RemoveRange(employee.User.BookTransactions);
                    
                    // Remove user ticket type transactions
                    _context.TicketTypeTransactions.RemoveRange(employee.User.TicketTypeTransactions);
                    
                    // Remove the employee and user
                    _context.Employees.Remove(employee);
                    _context.Users.Remove(employee.User);
                    
                    await _context.SaveChangesAsync();                
                    transaction.Commit();
    
                    return employeeModel;
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    // Log the specific error for debugging
                    Console.WriteLine($"Error deleting employee {id}: {ex.Message}");
                    Console.WriteLine($"Stack trace: {ex.StackTrace}");
                    throw new Exception($"Failed to delete employee: {ex.Message}", ex);
                }
            }
        }
        

    }
}
