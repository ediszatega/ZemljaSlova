﻿using System;
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
    public class FavouriteService : BaseCRUDService<Model.Favourite, FavouriteSearchObject, Database.Favourite, FavouriteInsertRequest, FavouriteUpdateRequest>, IFavouriteService
    {
        public FavouriteService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
