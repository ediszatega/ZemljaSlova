using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.Model.Enums;
using ZemljaSlova.Model.Reports;
using ZemljaSlova.Services.Database;
using iTextSharp.text;
using iTextSharp.text.pdf;
using System.IO;

namespace ZemljaSlova.Services
{
    public class ReportingService : IReportingService
    {
        private readonly _200036Context _context;

        public ReportingService(_200036Context context)
        {
            _context = context;
        }

        public async Task<BooksSoldReport> GetBooksSoldReportAsync(DateTime startDate, DateTime endDate)
        {
            var soldTransactions = await _context.BookTransactions
                .Include(bt => bt.Book)
                .ThenInclude(b => b.Authors)
                .Include(bt => bt.User)
                .Where(bt => bt.ActivityTypeId == (byte)ActivityType.Sold &&
                            bt.CreatedAt >= startDate &&
                            bt.CreatedAt <= endDate)
                .OrderByDescending(bt => bt.CreatedAt)
                .ToListAsync();

            var report = new BooksSoldReport
            {
                StartDate = startDate,
                EndDate = endDate,
                TotalBooksSold = soldTransactions.Select(bt => bt.BookId).Distinct().Count(),
                TotalTransactions = soldTransactions.Count,
                ReportPeriod = $"{startDate:dd.MM.yyyy} - {endDate:dd.MM.yyyy}"
            };

            // Get transactions with details
            foreach (var transaction in soldTransactions)
            {
                var book = transaction.Book;
                var authorNames = book?.Authors != null 
                    ? string.Join(", ", book.Authors.Select(a => $"{a.FirstName} {a.LastName}"))
                    : "Nepoznato";

                var orderItem = await _context.OrderItems
                    .Include(oi => oi.Order)
                    .ThenInclude(o => o.Member)
                    .ThenInclude(m => m.User)
                    .FirstOrDefaultAsync(oi => oi.BookId == transaction.BookId &&
                                             oi.Quantity == transaction.Quantity &&
                                             oi.Order.PurchasedAt.Date == transaction.CreatedAt.Date);

                var customerName = orderItem?.Order?.Member?.User != null
                    ? $"{orderItem.Order.Member.User.FirstName} {orderItem.Order.Member.User.LastName}"
                    : "Nepoznato";

                var employeeName = transaction.User != null
                    ? $"{transaction.User.FirstName} {transaction.User.LastName}"
                    : "Nepoznato";

                var unitPrice = book?.Price ?? 0;
                var totalPrice = unitPrice * transaction.Quantity;

                report.Transactions.Add(new BookSoldTransaction
                {
                    Id = transaction.Id,
                    BookTitle = book?.Title ?? "Nepoznato",
                    AuthorNames = authorNames,
                    Quantity = transaction.Quantity,
                    UnitPrice = unitPrice,
                    TotalPrice = totalPrice,
                    SoldDate = transaction.CreatedAt,
                    EmployeeName = employeeName,
                    CustomerName = customerName
                });

                report.TotalRevenue += totalPrice;
            }

            // Create book summaries
            var bookSummaries = soldTransactions
                .GroupBy(bt => bt.BookId)
                .Select(g => new BookSoldSummary
                {
                    BookId = g.Key,
                    BookTitle = g.First().Book?.Title ?? "Nepoznato",
                    AuthorNames = g.First().Book?.Authors != null
                        ? string.Join(", ", g.First().Book.Authors.Select(a => $"{a.FirstName} {a.LastName}"))
                        : "Nepoznato",
                    TotalQuantitySold = g.Sum(bt => bt.Quantity),
                    TotalRevenue = g.Sum(bt => (bt.Book?.Price ?? 0) * bt.Quantity),
                    AveragePrice = g.Average(bt => bt.Book?.Price ?? 0)
                })
                .OrderByDescending(bs => bs.TotalQuantitySold)
                .ToList();

            report.BookSummaries = bookSummaries;

            return report;
        }

        public async Task<BooksSoldReport> GetBooksSoldReportByMonthAsync(int year, int month)
        {
            var startDate = new DateTime(year, month, 1);
            var endDate = startDate.AddMonths(1).AddDays(-1);
            return await GetBooksSoldReportAsync(startDate, endDate);
        }

        public async Task<BooksSoldReport> GetBooksSoldReportByQuarterAsync(int year, int quarter)
        {
            var startMonth = (quarter - 1) * 3 + 1;
            var startDate = new DateTime(year, startMonth, 1);
            var endDate = startDate.AddMonths(3).AddDays(-1);
            return await GetBooksSoldReportAsync(startDate, endDate);
        }

        public async Task<BooksSoldReport> GetBooksSoldReportByYearAsync(int year)
        {
            var startDate = new DateTime(year, 1, 1);
            var endDate = new DateTime(year, 12, 31);
            return await GetBooksSoldReportAsync(startDate, endDate);
        }

        public async Task<byte[]> GenerateBooksSoldPdfReportAsync(DateTime startDate, DateTime endDate)
        {
            var report = await GetBooksSoldReportAsync(startDate, endDate);

            using (MemoryStream ms = new MemoryStream())
            {
                Document document = new Document(PageSize.A4, 25, 25, 30, 30);
                PdfWriter writer = PdfWriter.GetInstance(document, ms);

                document.Open();

                // Add title
                Font titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 18);
                Paragraph title = new Paragraph("Izvještaj o prodaji knjiga", titleFont);
                title.Alignment = Element.ALIGN_CENTER;
                document.Add(title);
                document.Add(new Paragraph(" "));

                // Add period
                Font periodFont = FontFactory.GetFont(FontFactory.HELVETICA, 12);
                Paragraph period = new Paragraph($"Period: {report.ReportPeriod}", periodFont);
                document.Add(period);
                document.Add(new Paragraph(" "));

                // Add summary
                Font summaryFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 12);
                document.Add(new Paragraph("Sažetak:", summaryFont));
                document.Add(new Paragraph($"Ukupno prodanih knjiga: {report.TotalBooksSold}"));
                document.Add(new Paragraph($"Ukupan prihod: {report.TotalRevenue:C}"));
                document.Add(new Paragraph($"Ukupno transakcija: {report.TotalTransactions}"));
                document.Add(new Paragraph(" "));

                // Add book summaries table
                if (report.BookSummaries.Any())
                {
                    document.Add(new Paragraph("Pregled po knjigama:", summaryFont));
                    document.Add(new Paragraph(" "));

                    PdfPTable table = new PdfPTable(5);
                    table.WidthPercentage = 100;

                    // Add headers
                    table.AddCell(new PdfPCell(new Phrase("Naslov knjige", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    table.AddCell(new PdfPCell(new Phrase("Autori", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    table.AddCell(new PdfPCell(new Phrase("Količina", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    table.AddCell(new PdfPCell(new Phrase("Ukupan prihod", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    table.AddCell(new PdfPCell(new Phrase("Prosječna cijena", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });

                    // Add data
                    foreach (var summary in report.BookSummaries)
                    {
                        table.AddCell(new PdfPCell(new Phrase(summary.BookTitle)));
                        table.AddCell(new PdfPCell(new Phrase(summary.AuthorNames)));
                        table.AddCell(new PdfPCell(new Phrase(summary.TotalQuantitySold.ToString())));
                        table.AddCell(new PdfPCell(new Phrase(summary.TotalRevenue.ToString("C"))));
                        table.AddCell(new PdfPCell(new Phrase(summary.AveragePrice.ToString("C"))));
                    }

                    document.Add(table);
                    document.Add(new Paragraph(" "));
                }

                // Add detailed transactions table
                if (report.Transactions.Any())
                {
                    document.Add(new Paragraph("Detaljne transakcije:", summaryFont));
                    document.Add(new Paragraph(" "));

                    PdfPTable transTable = new PdfPTable(7);
                    transTable.WidthPercentage = 100;

                    // Add headers
                    transTable.AddCell(new PdfPCell(new Phrase("Datum", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    transTable.AddCell(new PdfPCell(new Phrase("Knjiga", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    transTable.AddCell(new PdfPCell(new Phrase("Autori", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    transTable.AddCell(new PdfPCell(new Phrase("Količina", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    transTable.AddCell(new PdfPCell(new Phrase("Cijena", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    transTable.AddCell(new PdfPCell(new Phrase("Kupac", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });
                    transTable.AddCell(new PdfPCell(new Phrase("Uposlenik", summaryFont)) { BackgroundColor = BaseColor.LIGHT_GRAY });

                    // Add data
                    foreach (var transaction in report.Transactions.Take(50)) // Limit to first 50 for PDF
                    {
                        transTable.AddCell(new PdfPCell(new Phrase(transaction.SoldDate.ToString("dd.MM.yyyy"))));
                        transTable.AddCell(new PdfPCell(new Phrase(transaction.BookTitle)));
                        transTable.AddCell(new PdfPCell(new Phrase(transaction.AuthorNames)));
                        transTable.AddCell(new PdfPCell(new Phrase(transaction.Quantity.ToString())));
                        transTable.AddCell(new PdfPCell(new Phrase(transaction.TotalPrice.ToString("C"))));
                        transTable.AddCell(new PdfPCell(new Phrase(transaction.CustomerName)));
                        transTable.AddCell(new PdfPCell(new Phrase(transaction.EmployeeName)));
                    }

                    document.Add(transTable);

                    if (report.Transactions.Count > 50)
                    {
                        document.Add(new Paragraph($"Napomena: Prikazano je prvih 50 transakcija od ukupno {report.Transactions.Count}"));
                    }
                }

                document.Close();
                writer.Close();

                return ms.ToArray();
            }
        }
    }
}
