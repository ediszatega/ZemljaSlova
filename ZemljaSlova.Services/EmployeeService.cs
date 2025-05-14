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

        new public async Task<Model.Employee> GetById(int id)
        {
            var employee = await _context.Employees
                .Include(e => e.User)
                .FirstOrDefaultAsync(e => e.UserId == id);

            if (employee == null) return null;

            // Map to model but break circular reference
            var employeeModel = new Model.Employee
            {
                Id = employee.Id,
                UserId = employee.UserId,
                AccessLevel = employee.AccessLevel,
                User = new Model.User
                {
                    Id = employee.User.Id,
                    FirstName = employee.User.FirstName,
                    LastName = employee.User.LastName,
                    Email = employee.User.Email,
                    Gender = employee.User.Gender,
                }
            };

            return employeeModel;
        }
    }
}
