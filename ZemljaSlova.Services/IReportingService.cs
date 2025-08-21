using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ZemljaSlova.Model;
using ZemljaSlova.Model.Reports;

namespace ZemljaSlova.Services
{
    public interface IReportingService
    {
        // Books Sold Reports
        Task<BooksSoldReport> GetBooksSoldReportAsync(DateTime startDate, DateTime endDate);
        Task<byte[]> GenerateBooksSoldPdfReportAsync(DateTime startDate, DateTime endDate);
        Task<BooksSoldReport> GetBooksSoldReportByMonthAsync(int year, int month);
        Task<BooksSoldReport> GetBooksSoldReportByQuarterAsync(int year, int quarter);
        Task<BooksSoldReport> GetBooksSoldReportByYearAsync(int year);
        
        // Books Rented Reports
        Task<BooksRentedReport> GetBooksRentedReportAsync(DateTime startDate, DateTime endDate);
        Task<byte[]> GenerateBooksRentedPdfReportAsync(DateTime startDate, DateTime endDate);
        Task<BooksRentedReport> GetBooksRentedReportByMonthAsync(int year, int month);
        Task<BooksRentedReport> GetBooksRentedReportByQuarterAsync(int year, int quarter);
        Task<BooksRentedReport> GetBooksRentedReportByYearAsync(int year);
    }
}
