using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class EmployeeController : BaseCRUDController<Model.Employee, EmployeeSearchObject, EmployeeInsertRequest, EmployeeUpdateRequest>
    {
        private readonly IEmployeeService _employeeService;
        public EmployeeController(IEmployeeService service) : base(service) 
        {
            _employeeService = service;
        }

        [HttpPost("CreateEmployee")]
        public async Task<ActionResult<Model.Employee>> CreateEmployee(EmployeeInsertRequest request)
        {
            try
            {
                var employee = await _employeeService.CreateEmployee(request);
                return Ok(employee);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while creating the employee.");
            }
        }

        [HttpGet("GetEmployeeById/{id}")]
        public async Task<ActionResult<Model.Employee>> GetById(int id)
        {
            var employee = await _employeeService.GetById(id);
            if (employee == null) return NotFound();
            return Ok(employee);
        }
    }
}
