using System;
using System.Collections.Generic;

namespace ZemljaSlova.Services.Database;

public partial class OrderItem
{
    public int Id { get; set; }

    public int? BookId { get; set; }

    public int? TicketTypeId { get; set; }

    public int? MembershipId { get; set; }

    public int Quantity { get; set; }

    public int? DiscountId { get; set; }

    public int? VoucherId { get; set; }

    public int OrderId { get; set; }

    public virtual Book? Book { get; set; }

    public virtual Discount? Discount { get; set; }

    public virtual Membership? Membership { get; set; }

    public virtual Order Order { get; set; } = null!;

    public virtual TicketType? TicketType { get; set; }

    public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

    public virtual ICollection<UserBookClubTransaction> UserBookClubTransactions { get; set; } = new List<UserBookClubTransaction>();

    public virtual Voucher? Voucher { get; set; }
}
