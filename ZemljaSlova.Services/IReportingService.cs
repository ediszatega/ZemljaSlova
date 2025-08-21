using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Reports;

namespace ZemljaSlova.Services
{
    public interface IReportingService
    {
        Task<BooksSoldReport> GetBooksSoldReportAsync(DateTime startDate, DateTime endDate);
        Task<byte[]> GenerateBooksSoldPdfReportAsync(DateTime startDate, DateTime endDate);
        Task<BooksSoldReport> GetBooksSoldReportByMonthAsync(int year, int month);
        Task<BooksSoldReport> GetBooksSoldReportByQuarterAsync(int year, int quarter);
        Task<BooksSoldReport> GetBooksSoldReportByYearAsync(int year);
    }
}
