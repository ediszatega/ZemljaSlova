using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;
using Microsoft.AspNetCore.Authorization;
using ZemljaSlova.Model.Enums;
using Microsoft.AspNetCore.Http;

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

        [HttpPost("CreateEmployee/with-image")]
        [Consumes("multipart/form-data")]
        public async Task<Model.Employee> CreateEmployeeWithImage()
        {
            return await _employeeService.CreateEmployeeFromForm(Request.Form);
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

        [HttpPut("UpdateEmployee/{id}/with-image")]
        [Consumes("multipart/form-data")]
        public async Task<Model.Employee> UpdateEmployeeWithImage(int id)
        {
            return await _employeeService.UpdateEmployeeFromForm(id, Request.Form);
        }

        [HttpPut("UpdateSelfProfile/{id}")]
        public async Task<ActionResult<Model.Employee>> UpdateSelfProfile(int id, [FromBody] EmployeeSelfUpdateRequest request)
        {
            try
            {
                var employee = await _employeeService.UpdateSelfProfile(id, request);
                return Ok(employee);
            }
            catch (Exception)
            {
                return StatusCode(500, "Greška prilikom ažuriranja profila zaposlenog.");
            }
        }

        [HttpPut("UpdateSelfProfile/{id}/with-image")]
        [Consumes("multipart/form-data")]
        public async Task<Model.Employee> UpdateSelfProfileWithImage(int id)
        {
            return await _employeeService.UpdateSelfProfileFromForm(id, Request.Form);
        }
        
        [HttpGet("GetEmployeeByUserId/{userId}")]
        public ActionResult<Model.Employee> GetEmployeeByUserId(int userId)
        {
            try
            {
                var employee = _employeeService.GetByUserId(userId);
                if (employee == null)
                {
                    return NotFound("Employee not found for the given user ID.");
                }
                return Ok(employee);
            }
            catch (Exception ex)
            {
                return StatusCode(500, "An error occurred while retrieving the employee.");
            }
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = UserRoles.Admin)]
        public override async Task<Model.Employee> Delete(int id)
        {
            return await _employeeService.Delete(id);
        }

        [HttpGet("{id}/image")]
        public IActionResult GetEmployeeImage(int id)
        {
            try
            {
                var employee = _employeeService.GetById(id);
                if (employee?.User?.Image == null || employee.User.Image.Length == 0)
                {
                    return NotFound("Slika nije pronađena");
                }

                return File(employee.User.Image, "image/jpeg");
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Greška prilikom dobavljanja slike");
            }
        }
    }
}
