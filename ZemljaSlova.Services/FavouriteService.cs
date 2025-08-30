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
            if (search.IsBookIncluded != false)
            {
                query = query.Include(x => x.Book);
            }

            if (search.IsMemberIncluded != false)
            {
                query = query.Include(x => x.Member).ThenInclude(m => m.User);
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

        public override Model.Favourite GetById(int id)
        {
            var entity = Context.Favourites
                .Include(f => f.Book)
                .Include(f => f.Member)
                    .ThenInclude(m => m.User)
                .FirstOrDefault(f => f.Id == id);

            if (entity == null)
            {
                return null;
            }

            return Mapper.Map<Model.Favourite>(entity);
        }

        public bool Unfavourite(int memberId, int bookId)
        {
            var favourite = Context.Favourites
                .FirstOrDefault(f => f.MemberId == memberId && f.BookId == bookId);
            
            if (favourite == null)
            {
                return false;
            }

            Context.Favourites.Remove(favourite);
            Context.SaveChanges();
            return true;
        }

        public override void BeforeInsert(FavouriteInsertRequest request, Database.Favourite entity)
        {
            // Check if book is already favourited by this member
            var existingFavourite = Context.Favourites
                .Any(f => f.MemberId == request.MemberId && f.BookId == request.BookId);
            
            if (existingFavourite)
            {
                throw new UserException("Knjiga je već u favoritima.");
            }
        }
    }
}
