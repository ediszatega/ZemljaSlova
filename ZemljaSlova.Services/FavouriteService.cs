using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;

namespace ZemljaSlova.Services
{
    public class FavouriteService : BaseCRUDService<Model.Favourite, FavouriteSearchObject, Database.Favourite, FavouriteInsertRequest, FavouriteUpdateRequest>, IFavouriteService
    {
        public FavouriteService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Favourite> AddFilter(FavouriteSearchObject search, IQueryable<Database.Favourite> query)
        {
            if (search.IsBookIncluded == true)
            {
                query = query.Include(x => x.Book);
            }

            if (search.IsMemberIncluded == true)
            {
                query = query.Include(x => x.Member);
            }

            if (search.MemberId.HasValue)
            {
                query = query.Where(x => x.MemberId == search.MemberId.Value);
            }

            if (search.BookId.HasValue)
            {
                query = query.Where(x => x.BookId == search.BookId.Value);
            }

            return base.AddFilter(search, query);
        }
    }
}
