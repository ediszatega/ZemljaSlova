﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;

namespace ZemljaSlova.Services
{
    public interface IBookReservationService : ICRUDService<BookReservation, BookReservationSearchObject, BookReservationUpsertRequest, BookReservationUpsertRequest>
    {
    }
}
