using System;
using System.Collections.Generic;

namespace ZemljaSlova.Model.Reports
{
    public class BooksRentedReport
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int TotalBooksRented { get; set; }
        public int TotalActiveRentals { get; set; }
        public int TotalOverdueRentals { get; set; }
        public int TotalTransactions { get; set; }
        public List<BookRentedTransaction> Transactions { get; set; } = new List<BookRentedTransaction>();
        public List<BookRentedSummary> BookSummaries { get; set; } = new List<BookRentedSummary>();
        public string ReportPeriod { get; set; } = string.Empty;
    }

    public class BookRentedTransaction
    {
        public int Id { get; set; }
        public string BookTitle { get; set; } = string.Empty;
        public string AuthorNames { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public DateTime RentedDate { get; set; }
        public DateTime? ReturnDate { get; set; }
        public DateTime DueDate { get; set; }
        public string CustomerName { get; set; } = string.Empty;
        public string EmployeeName { get; set; } = string.Empty;
        public bool IsOverdue { get; set; }
        public bool IsReturned { get; set; }
        public int DaysOverdue { get; set; }
    }

    public class BookRentedSummary
    {
        public int BookId { get; set; }
        public string BookTitle { get; set; } = string.Empty;
        public string AuthorNames { get; set; } = string.Empty;
        public int TotalTimesRented { get; set; }
        public int TotalQuantityRented { get; set; }
        public int ActiveRentals { get; set; }
        public int OverdueRentals { get; set; }
    }
}
