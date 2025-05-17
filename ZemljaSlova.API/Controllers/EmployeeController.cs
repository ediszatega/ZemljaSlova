using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;

namespace ZemljaSlova.API.Controllers
{
    //[Authorize]
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
        
        [HttpPut("UpdateEmployee/{id}")]
        public async Task<ActionResult<Model.Employee>> UpdateEmployee(int id, [FromBody] EmployeeUpdateRequest request)
        {
            try
            {
                var employee = await _employeeService.UpdateEmployee(id, request);
                return Ok(employee);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while updating the employee.");
            }
        }
    }
}
