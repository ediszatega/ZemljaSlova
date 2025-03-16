using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class EmployeeController : BaseCRUDController<Model.Employee, EmployeeSearchObject, EmployeeUpsertRequest, EmployeeUpsertRequest>
    {
        public EmployeeController(IEmployeeService service) : base(service) { }
    }
}
