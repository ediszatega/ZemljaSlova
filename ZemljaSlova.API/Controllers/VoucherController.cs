﻿using Microsoft.AspNetCore.Mvc;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class VoucherController : BaseCRUDController<Model.Voucher, VoucherSearchObject, VoucherUpsertRequest, VoucherUpsertRequest>
    {
        public VoucherController(IVoucherService service) : base(service) { }
    }
}
