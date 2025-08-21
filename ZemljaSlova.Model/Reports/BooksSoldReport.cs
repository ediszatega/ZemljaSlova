using System;
using System.Collections.Generic;

namespace ZemljaSlova.Model.Reports
{
    public class BooksSoldReport
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int TotalBooksSold { get; set; }
        public decimal TotalRevenue { get; set; }
        public int TotalTransactions { get; set; }
        public List<BookSoldTransaction> Transactions { get; set; } = new List<BookSoldTransaction>();
        public List<BookSoldSummary> BookSummaries { get; set; } = new List<BookSoldSummary>();
        public string ReportPeriod { get; set; } = string.Empty;
    }

    public class BookSoldTransaction
    {
        public int Id { get; set; }
        public string BookTitle { get; set; } = string.Empty;
        public string AuthorNames { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime SoldDate { get; set; }
        public string EmployeeName { get; set; } = string.Empty;
        public string CustomerName { get; set; } = string.Empty;
    }

    public class BookSoldSummary
    {
        public int BookId { get; set; }
        public string BookTitle { get; set; } = string.Empty;
        public string AuthorNames { get; set; } = string.Empty;
        public int TotalQuantitySold { get; set; }
        public decimal TotalRevenue { get; set; }
        public decimal AveragePrice { get; set; }
    }
}
