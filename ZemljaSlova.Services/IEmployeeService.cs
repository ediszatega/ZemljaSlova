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
    public interface IEmployeeService : ICRUDService<Employee, EmployeeSearchObject, EmployeeInsertRequest, EmployeeUpdateRequest>
    {
        public Task<Model.Employee> CreateEmployee(EmployeeInsertRequest request);
        
        public Task<Model.Employee> UpdateEmployee(int id, EmployeeUpdateRequest request);
        
        public Model.Employee GetByUserId(int userId);
    }
}
