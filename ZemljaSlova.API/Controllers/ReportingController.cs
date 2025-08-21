using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using ZemljaSlova.Model.Reports;
using ZemljaSlova.Services;

namespace ZemljaSlova.API.Controllers
{
    //[Authorize]
    [ApiController]
    [Route("[controller]")]
    public class ReportingController : ControllerBase
    {
        private readonly IReportingService _reportingService;

        public ReportingController(IReportingService reportingService)
        {
            _reportingService = reportingService;
        }

        [HttpGet("books-sold")]
        public async Task<ActionResult<BooksSoldReport>> GetBooksSoldReport(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate)
        {
            try
            {
                var report = await _reportingService.GetBooksSoldReportAsync(startDate, endDate);
                return Ok(report);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-sold/month/{year}/{month}")]
        public async Task<ActionResult<BooksSoldReport>> GetBooksSoldReportByMonth(
            int year, int month)
        {
            try
            {
                if (month < 1 || month > 12)
                    return BadRequest("Mjesec mora biti između 1 i 12");

                var report = await _reportingService.GetBooksSoldReportByMonthAsync(year, month);
                return Ok(report);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-sold/quarter/{year}/{quarter}")]
        public async Task<ActionResult<BooksSoldReport>> GetBooksSoldReportByQuarter(
            int year, int quarter)
        {
            try
            {
                if (quarter < 1 || quarter > 4)
                    return BadRequest("Kvartal mora biti između 1 i 4");

                var report = await _reportingService.GetBooksSoldReportByQuarterAsync(year, quarter);
                return Ok(report);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-sold/year/{year}")]
        public async Task<ActionResult<BooksSoldReport>> GetBooksSoldReportByYear(int year)
        {
            try
            {
                if (year < 2000 || year > 2100)
                    return BadRequest("Godina mora biti između 2000 i 2100");

                var report = await _reportingService.GetBooksSoldReportByYearAsync(year);
                return Ok(report);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-sold/pdf")]
        public async Task<IActionResult> DownloadBooksSoldPdfReport(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate)
        {
            try
            {
                var pdfBytes = await _reportingService.GenerateBooksSoldPdfReportAsync(startDate, endDate);
                
                var fileName = $"izvjestaj_prodaja_knjiga_{startDate:yyyyMMdd}_{endDate:yyyyMMdd}.pdf";
                
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju PDF izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-sold/pdf/month/{year}/{month}")]
        public async Task<IActionResult> DownloadBooksSoldPdfReportByMonth(
            int year, int month)
        {
            try
            {
                if (month < 1 || month > 12)
                    return BadRequest("Mjesec mora biti između 1 i 12");

                var startDate = new DateTime(year, month, 1);
                var endDate = startDate.AddMonths(1).AddDays(-1);
                
                var pdfBytes = await _reportingService.GenerateBooksSoldPdfReportAsync(startDate, endDate);
                
                var monthName = startDate.ToString("MMMM", new System.Globalization.CultureInfo("hr-HR"));
                var fileName = $"izvjestaj_prodaja_knjiga_{monthName}_{year}.pdf";
                
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju PDF izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-sold/pdf/quarter/{year}/{quarter}")]
        public async Task<IActionResult> DownloadBooksSoldPdfReportByQuarter(
            int year, int quarter)
        {
            try
            {
                if (quarter < 1 || quarter > 4)
                    return BadRequest("Kvartal mora biti između 1 i 4");

                var startMonth = (quarter - 1) * 3 + 1;
                var startDate = new DateTime(year, startMonth, 1);
                var endDate = startDate.AddMonths(3).AddDays(-1);
                
                var pdfBytes = await _reportingService.GenerateBooksSoldPdfReportAsync(startDate, endDate);
                
                var fileName = $"izvjestaj_prodaja_knjiga_Q{quarter}_{year}.pdf";
                
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju PDF izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-sold/pdf/year/{year}")]
        public async Task<IActionResult> DownloadBooksSoldPdfReportByYear(int year)
        {
            try
            {
                if (year < 2000 || year > 2100)
                    return BadRequest("Godina mora biti između 2000 i 2100");

                var startDate = new DateTime(year, 1, 1);
                var endDate = new DateTime(year, 12, 31);
                
                var pdfBytes = await _reportingService.GenerateBooksSoldPdfReportAsync(startDate, endDate);
                
                var fileName = $"izvjestaj_prodaja_knjiga_{year}.pdf";
                
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju PDF izvještaja: {ex.Message}");
            }
        }

        // Books Rented Reports
        [HttpGet("books-rented")]
        public async Task<ActionResult<BooksRentedReport>> GetBooksRentedReport(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate)
        {
            try
            {
                var report = await _reportingService.GetBooksRentedReportAsync(startDate, endDate);
                return Ok(report);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-rented/month/{year}/{month}")]
        public async Task<ActionResult<BooksRentedReport>> GetBooksRentedReportByMonth(
            int year, int month)
        {
            try
            {
                if (month < 1 || month > 12)
                    return BadRequest("Mjesec mora biti između 1 i 12");

                var report = await _reportingService.GetBooksRentedReportByMonthAsync(year, month);
                return Ok(report);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-rented/quarter/{year}/{quarter}")]
        public async Task<ActionResult<BooksRentedReport>> GetBooksRentedReportByQuarter(
            int year, int quarter)
        {
            try
            {
                if (quarter < 1 || quarter > 4)
                    return BadRequest("Kvartal mora biti između 1 i 4");

                var report = await _reportingService.GetBooksRentedReportByQuarterAsync(year, quarter);
                return Ok(report);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-rented/year/{year}")]
        public async Task<ActionResult<BooksRentedReport>> GetBooksRentedReportByYear(int year)
        {
            try
            {
                if (year < 2000 || year > 2100)
                    return BadRequest("Godina mora biti između 2000 i 2100");

                var report = await _reportingService.GetBooksRentedReportByYearAsync(year);
                return Ok(report);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-rented/pdf")]
        public async Task<IActionResult> DownloadBooksRentedPdfReport(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate)
        {
            try
            {
                var pdfBytes = await _reportingService.GenerateBooksRentedPdfReportAsync(startDate, endDate);
                
                var fileName = $"izvjestaj_iznajmljivanje_knjiga_{startDate:yyyyMMdd}_{endDate:yyyyMMdd}.pdf";
                
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju PDF izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-rented/pdf/month/{year}/{month}")]
        public async Task<IActionResult> DownloadBooksRentedPdfReportByMonth(
            int year, int month)
        {
            try
            {
                if (month < 1 || month > 12)
                    return BadRequest("Mjesec mora biti između 1 i 12");

                var startDate = new DateTime(year, month, 1);
                var endDate = startDate.AddMonths(1).AddDays(-1);
                
                var pdfBytes = await _reportingService.GenerateBooksRentedPdfReportAsync(startDate, endDate);
                
                var monthName = startDate.ToString("MMMM", new System.Globalization.CultureInfo("hr-HR"));
                var fileName = $"izvjestaj_iznajmljivanje_knjiga_{monthName}_{year}.pdf";
                
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju PDF izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-rented/pdf/quarter/{year}/{quarter}")]
        public async Task<IActionResult> DownloadBooksRentedPdfReportByQuarter(
            int year, int quarter)
        {
            try
            {
                if (quarter < 1 || quarter > 4)
                    return BadRequest("Kvartal mora biti između 1 i 4");

                var startMonth = (quarter - 1) * 3 + 1;
                var startDate = new DateTime(year, startMonth, 1);
                var endDate = startDate.AddMonths(3).AddDays(-1);
                
                var pdfBytes = await _reportingService.GenerateBooksRentedPdfReportAsync(startDate, endDate);
                
                var fileName = $"izvjestaj_iznajmljivanje_knjiga_Q{quarter}_{year}.pdf";
                
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju PDF izvještaja: {ex.Message}");
            }
        }

        [HttpGet("books-rented/pdf/year/{year}")]
        public async Task<IActionResult> DownloadBooksRentedPdfReportByYear(int year)
        {
            try
            {
                if (year < 2000 || year > 2100)
                    return BadRequest("Godina mora biti između 2000 i 2100");

                var startDate = new DateTime(year, 1, 1);
                var endDate = new DateTime(year, 12, 31);
                
                var pdfBytes = await _reportingService.GenerateBooksRentedPdfReportAsync(startDate, endDate);
                
                var fileName = $"izvjestaj_iznajmljivanje_knjiga_{year}.pdf";
                
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                return BadRequest($"Greška pri generiranju PDF izvještaja: {ex.Message}");
            }
        }
    }
}
