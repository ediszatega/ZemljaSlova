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
using Microsoft.AspNetCore.Http;
using System.IO;

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

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(e => e.User.FirstName.ToLower().Contains(search.Name.ToLower()) || e.User.LastName.ToLower().Contains(search.Name.ToLower()));
            }

            if (!string.IsNullOrEmpty(search.Gender))
            {
                query = query.Where(e => e.User.Gender == search.Gender);
            }

            if (!string.IsNullOrEmpty(search.AccessLevel))
            {
                query = query.Where(e => e.AccessLevel == search.AccessLevel);
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
        
        public override void BeforeDelete(Database.Employee entity)
        {
            // Check if employee has book transactions
            var hasBookTransactions = _context.BookTransactions
                .Any(bt => bt.UserId == entity.UserId);
            
            if (hasBookTransactions)
            {
                throw new UserException("Nije moguće izbrisati uposlenika koji ima ranije transakcije knjiga.");
            }

            // Check if employee has ticket type transactions
            var hasTicketTransactions = _context.TicketTypeTransactions
                .Any(ttt => ttt.UserId == entity.UserId);
            
            if (hasTicketTransactions)
            {
                throw new UserException("Nije moguće izbrisati uposlenika koji ima ranije transakcije ulaznica.");
            }
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

                    BeforeDelete(employee);

                    var employeeModel = _mapper.Map<Model.Employee>(employee);
                    
                    // Remove the employee and user
                    _context.Employees.Remove(employee);
                    _context.Users.Remove(employee.User);
                    
                    await _context.SaveChangesAsync();                
                    transaction.Commit();
                    return employeeModel;
                }
                catch (UserException)
                {
                    transaction.Rollback();
                    throw;
                }
            }
        }

        public async Task<Model.Employee> CreateEmployeeFromForm(IFormCollection form)
        {
            // Extract form data
            string firstName = form["firstName"].FirstOrDefault() ?? "";
            string lastName = form["lastName"].FirstOrDefault() ?? "";
            string email = form["email"].FirstOrDefault() ?? "";
            string password = form["password"].FirstOrDefault() ?? "";
            string accessLevel = form["accessLevel"].FirstOrDefault() ?? "";
            string? gender = form["gender"].FirstOrDefault();

            // Handle image file
            byte[] imageBytes = null;
            if (form.Files.Count > 0 && form.Files[0].Length > 0)
            {
                var imageFile = form.Files[0];
                using (var memoryStream = new MemoryStream())
                {
                    await imageFile.CopyToAsync(memoryStream);
                    imageBytes = memoryStream.ToArray();
                }
            }

            // Create user first
            var user = new UserInsertRequest
            {
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Password = password,
                Gender = gender
            };

            Model.User createdUser = _userService.Insert(user);

            // Update user with image if provided
            if (imageBytes != null)
            {
                var userEntity = _context.Users.FirstOrDefault(u => u.Id == createdUser.Id);
                if (userEntity != null)
                {
                    userEntity.Image = imageBytes;
                }
            }

            await _context.SaveChangesAsync();

            // Create employee
            var employee = new Database.Employee
            {
                UserId = createdUser.Id,
                AccessLevel = accessLevel
            };

            _context.Employees.Add(employee);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Employee>(employee);
        }

        public async Task<Model.Employee> UpdateEmployeeFromForm(int id, IFormCollection form)
        {
            var employee = await _context.Employees
                .Include(e => e.User)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (employee == null)
            {
                throw new UserException("Uposlenik nije pronađen.");
            }

            // Extract form data
            string firstName = form["firstName"].FirstOrDefault() ?? "";
            string lastName = form["lastName"].FirstOrDefault() ?? "";
            string email = form["email"].FirstOrDefault() ?? "";
            string accessLevel = form["accessLevel"].FirstOrDefault() ?? "";
            string? gender = form["gender"].FirstOrDefault();

            // Update user data
            employee.User.FirstName = firstName;
            employee.User.LastName = lastName;
            employee.User.Email = email;
            employee.User.Gender = gender;
            employee.AccessLevel = accessLevel;

            // Handle image file
            if (form.Files.Count > 0 && form.Files[0].Length > 0)
            {
                var imageFile = form.Files[0];
                using (var memoryStream = new MemoryStream())
                {
                    await imageFile.CopyToAsync(memoryStream);
                    employee.User.Image = memoryStream.ToArray();
                }
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Employee>(employee);
        }

        public async Task<Model.Employee> UpdateSelfProfile(int id, EmployeeSelfUpdateRequest request)
        {
            var employee = await _context.Employees
                .Include(e => e.User)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (employee == null)
            {
                throw new UserException("Uposlenik nije pronađen.");
            }

            // Update user data (excluding access level)
            employee.User.FirstName = request.FirstName;
            employee.User.LastName = request.LastName;
            employee.User.Email = request.Email;
            employee.User.Gender = request.Gender;

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Employee>(employee);
        }

        public async Task<Model.Employee> UpdateSelfProfileFromForm(int id, IFormCollection form)
        {
            var employee = await _context.Employees
                .Include(e => e.User)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (employee == null)
            {
                throw new UserException("Uposlenik nije pronađen.");
            }

            // Extract form data (excluding access level)
            string firstName = form["firstName"].FirstOrDefault() ?? "";
            string lastName = form["lastName"].FirstOrDefault() ?? "";
            string email = form["email"].FirstOrDefault() ?? "";
            string? gender = form["gender"].FirstOrDefault();

            // Update user data (excluding access level)
            employee.User.FirstName = firstName;
            employee.User.LastName = lastName;
            employee.User.Email = email;
            employee.User.Gender = gender;

            // Handle image file
            if (form.Files.Count > 0 && form.Files[0].Length > 0)
            {
                var imageFile = form.Files[0];
                using (var memoryStream = new MemoryStream())
                {
                    await imageFile.CopyToAsync(memoryStream);
                    employee.User.Image = memoryStream.ToArray();
                }
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Employee>(employee);
        }

    }
}
