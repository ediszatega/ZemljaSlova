using System;
using System.Collections.Generic;

namespace ZemljaSlova.Model.Reports
{
    public class MembersReport
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int TotalActiveMembers { get; set; }
        public int NewMembersInPeriod { get; set; }
        public int ExpiredMemberships { get; set; }
        public int TotalMemberships { get; set; }
        public string ReportPeriod { get; set; } = string.Empty;
        public List<MemberSummary> MemberSummaries { get; set; } = new List<MemberSummary>();
        public List<MembershipActivity> MembershipActivities { get; set; } = new List<MembershipActivity>();
    }

    public class MemberSummary
    {
        public int MemberId { get; set; }
        public string MemberName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime? MembershipStartDate { get; set; }
        public DateTime? MembershipEndDate { get; set; }
        public bool IsActive { get; set; }
        public int TotalRentals { get; set; }
        public int TotalPurchases { get; set; }
    }

    public class MembershipActivity
    {
        public int Id { get; set; }
        public string MemberName { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Status { get; set; } = string.Empty;
    }
}
