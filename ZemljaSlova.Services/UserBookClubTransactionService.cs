using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class UserBookClubTransactionService : BaseCRUDService<Model.UserBookClubTransaction, UserBookClubTransactionSearchObject, Database.UserBookClubTransaction, UserBookClubTransactionInsertRequest, UserBookClubTransactionUpdateRequest>, IUserBookClubTransactionService
    {
        public UserBookClubTransactionService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
