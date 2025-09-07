using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ZemljaSlova.Services;
using ZemljaSlova.Model.Enums;

namespace ZemljaSlova.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class BookClubPointsController : ControllerBase
    {
        private readonly IBookClubPointsService _bookClubPointsService;
        private readonly IUserBookClubService _userBookClubService;

        public BookClubPointsController(IBookClubPointsService bookClubPointsService, IUserBookClubService userBookClubService)
        {
            _bookClubPointsService = bookClubPointsService;
            _userBookClubService = userBookClubService;
        }

        [HttpGet("member/{memberId}/current")]
        public async Task<IActionResult> GetCurrentYearPoints(int memberId)
        {
            try
            {
                var points = await _bookClubPointsService.GetCurrentYearPointsAsync(memberId);
                var userBookClub = await _userBookClubService.GetCurrentYearByMemberAsync(memberId);
                
                var result = new
                {
                    MemberId = memberId,
                    Year = DateTime.Now.Year,
                    TotalPoints = points,
                    UserBookClub = userBookClub
                };

                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("member/{memberId}/year/{year}")]
        public async Task<IActionResult> GetYearPoints(int memberId, int year)
        {
            try
            {
                var points = await _bookClubPointsService.GetTotalPointsForYearAsync(memberId, year);
                var userBookClub = await _userBookClubService.GetByMemberAndYearAsync(memberId, year);
                
                var result = new
                {
                    MemberId = memberId,
                    Year = year,
                    TotalPoints = points,
                    UserBookClub = userBookClub
                };

                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("member/{memberId}/transactions/{year}")]
        public async Task<IActionResult> GetTransactionsForYear(int memberId, int year)
        {
            try
            {
                var transactions = await _bookClubPointsService.GetTransactionsForYearAsync(memberId, year);
                return Ok(transactions);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("member/{memberId}/history")]
        public async Task<IActionResult> GetMemberHistory(int memberId)
        {
            try
            {
                var userBookClubs = await _userBookClubService.GetByMemberAsync(memberId);
                return Ok(userBookClubs);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("leaderboard")]
        public async Task<IActionResult> GetLeaderboard([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var currentYear = DateTime.Now.Year;
                var leaderboard = await _bookClubPointsService.GetLeaderboardAsync(currentYear, page, pageSize);
                
                return Ok(leaderboard);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
