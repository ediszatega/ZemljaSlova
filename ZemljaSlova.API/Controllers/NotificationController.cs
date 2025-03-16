using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NotificationController : BaseCRUDController<Model.Notification, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>
    {
        public NotificationController(INotificationService service) : base(service) { }
    }
}
