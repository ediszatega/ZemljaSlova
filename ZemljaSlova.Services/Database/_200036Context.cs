using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace ZemljaSlova.Services.Database;

public partial class _200036Context : DbContext
{
    public _200036Context()
    {
    }

    public _200036Context(DbContextOptions<_200036Context> options)
        : base(options)
    {
    }

    public virtual DbSet<Author> Authors { get; set; }

    public virtual DbSet<Book> Books { get; set; }

    public virtual DbSet<BookAuthor> BookAuthors { get; set; }

    public virtual DbSet<BookReservation> BookReservations { get; set; }

    public virtual DbSet<BookTransaction> BookTransactions { get; set; }

    public virtual DbSet<Discount> Discounts { get; set; }

    public virtual DbSet<Employee> Employees { get; set; }

    public virtual DbSet<Event> Events { get; set; }

    public virtual DbSet<Favourite> Favourites { get; set; }

    public virtual DbSet<Member> Members { get; set; }

    public virtual DbSet<Membership> Memberships { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<Order> Orders { get; set; }

    public virtual DbSet<OrderItem> OrderItems { get; set; }

    public virtual DbSet<Recommendation> Recommendations { get; set; }

    public virtual DbSet<Ticket> Tickets { get; set; }

    public virtual DbSet<TicketType> TicketTypes { get; set; }

    public virtual DbSet<TicketTypeTransaction> TicketTypeTransactions { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserBookClub> UserBookClubs { get; set; }

    public virtual DbSet<UserBookClubTransaction> UserBookClubTransactions { get; set; }

    public virtual DbSet<Voucher> Vouchers { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost\\SQLEXPRESS; Initial Catalog=200036; Integrated Security=True;TrustServerCertificate=true;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Author>(entity =>
        {
            entity.ToTable("Author");

            entity.Property(e => e.DateOfBirth).HasColumnType("datetime");
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.Genre).HasMaxLength(50);
            entity.Property(e => e.LastName).HasMaxLength(100);
        });

        modelBuilder.Entity<BookAuthor>(entity =>
        {
            entity.HasKey(e => new { e.BookId, e.AuthorId });
            entity.ToTable("BookAuthor");

            entity.HasOne(e => e.Book)
                .WithMany()
                .HasForeignKey(e => e.BookId)
                .HasConstraintName("FK_BookAuthor_Book");

            entity.HasOne(e => e.Author)
                .WithMany()
                .HasForeignKey(e => e.AuthorId)
                .HasConstraintName("FK_BookAuthor_Author");
        });

        modelBuilder.Entity<Book>(entity =>
        {
            entity.ToTable("Book");

            entity.Property(e => e.Binding).HasMaxLength(50);
            entity.Property(e => e.DateOfPublish).HasColumnType("datetime");
            entity.Property(e => e.Dimensions).HasMaxLength(50);
            entity.Property(e => e.Genre).HasMaxLength(50);
            entity.Property(e => e.Language).HasMaxLength(50);
            entity.Property(e => e.Price).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Publisher).HasMaxLength(255);
            entity.Property(e => e.Title).HasMaxLength(255);
            entity.Property(e => e.Weight).HasColumnType("decimal(5, 2)");

            entity.HasOne(d => d.Discount).WithMany(p => p.Books)
                .HasForeignKey(d => d.DiscountId)
                .HasConstraintName("FK_Book_Discount");

            entity.HasMany(d => d.Authors)
                .WithMany(p => p.Books)
                .UsingEntity<BookAuthor>();

            entity.Ignore("OrderItems");
        });

        modelBuilder.Entity<BookReservation>(entity =>
        {
            entity.ToTable("BookReservation");

            entity.Property(e => e.ReservedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Book).WithMany(p => p.BookReservations)
                .HasForeignKey(d => d.BookId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_BookReservation_Book");

            entity.HasOne(d => d.Member).WithMany(p => p.BookReservations)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_BookReservation_Member");
        });

        modelBuilder.Entity<BookTransaction>(entity =>
        {
            entity.ToTable("BookTransaction");

            entity.Property(e => e.CreatedAt).HasColumnType("datetime");
            entity.Property(e => e.Data).IsUnicode(false);

            entity.HasOne(d => d.Book).WithMany(p => p.BookTransactions)
                .HasForeignKey(d => d.BookId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_BookTransaction_Book");

            entity.HasOne(d => d.User).WithMany(p => p.BookTransactions)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_BookTransaction_User");
        });

        modelBuilder.Entity<Discount>(entity =>
        {
            entity.ToTable("Discount");

            entity.Property(e => e.Code).HasMaxLength(50);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.DiscountPercentage).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.EndDate).HasColumnType("datetime");
            entity.Property(e => e.Name).HasMaxLength(100);
            entity.Property(e => e.StartDate).HasColumnType("datetime");
        });

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK_Employee_1");

            entity.ToTable("Employee");

            entity.Property(e => e.AccessLevel).HasMaxLength(50);

            entity.HasOne(d => d.User).WithMany(p => p.Employees)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Employee_User");
        });

        modelBuilder.Entity<Event>(entity =>
        {
            entity.ToTable("Event");

            entity.Property(e => e.EndAt).HasColumnType("datetime");
            entity.Property(e => e.Location).HasMaxLength(255);
            entity.Property(e => e.Organizer).HasMaxLength(255);
            entity.Property(e => e.StartAt).HasColumnType("datetime");
            entity.Property(e => e.Title).HasMaxLength(255);
        });

        modelBuilder.Entity<Favourite>(entity =>
        {
            entity.HasOne(d => d.Book).WithMany(p => p.Favourites)
                .HasForeignKey(d => d.BookId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Favourites_Book");

            entity.HasOne(d => d.Member).WithMany(p => p.Favourites)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Favourites_Member");
        });

        modelBuilder.Entity<Member>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK_Member_1");

            entity.ToTable("Member");

            entity.Property(e => e.DateOfBirth).HasColumnType("datetime");
            entity.Property(e => e.JoinedAt).HasColumnType("datetime");

            entity.HasOne(d => d.User).WithMany(p => p.Members)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Member_User");
        });

        modelBuilder.Entity<Membership>(entity =>
        {
            entity.ToTable("Membership");

            entity.Property(e => e.EndDate).HasColumnType("datetime");
            entity.Property(e => e.StartDate).HasColumnType("datetime");

            entity.HasOne(d => d.Member).WithMany(p => p.Memberships)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Membership_Member");
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.ToTable("Notification");

            entity.Property(e => e.RecievedAt).HasColumnType("datetime");
            entity.Property(e => e.Title).HasMaxLength(50);

            entity.HasOne(d => d.BookReservation).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.BookReservationId)
                .HasConstraintName("FK_Notification_BookReservation");

            entity.HasOne(d => d.Membership).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.MembershipId)
                .HasConstraintName("FK_Notification_Membership");

            entity.HasOne(d => d.Order).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.OrderId)
                .HasConstraintName("FK_Notification_Order");

            entity.HasOne(d => d.User).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Notification_User");
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.ToTable("Order");

            entity.Property(e => e.Amount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.DiscountAmount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.PaymentIntentId).HasMaxLength(255);
            entity.Property(e => e.PaymentMethodId).HasMaxLength(50);
            entity.Property(e => e.PaymentStatus).HasMaxLength(50);
            entity.Property(e => e.PurchasedAt).HasColumnType("datetime");
            entity.Property(e => e.ShippingAddress).HasMaxLength(255);
            entity.Property(e => e.ShippingCity).HasMaxLength(50);
            entity.Property(e => e.ShippingCountry).HasMaxLength(100);
            entity.Property(e => e.ShippingEmail).HasMaxLength(100);
            entity.Property(e => e.ShippingPhoneNumber).HasMaxLength(50);
            entity.Property(e => e.ShippingPostalCode).HasMaxLength(20);

            entity.HasOne(d => d.AppliedVoucher).WithMany(p => p.OrderAppliedVouchers)
                .HasForeignKey(d => d.AppliedVoucherId)
                .HasConstraintName("FK_Order_Voucher1");

            entity.HasOne(d => d.Discount).WithMany(p => p.Orders)
                .HasForeignKey(d => d.DiscountId)
                .HasConstraintName("FK_Order_Discount");

            entity.HasOne(d => d.Member).WithMany(p => p.Orders)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Order_Member");

            entity.HasOne(d => d.Voucher).WithMany(p => p.OrderVouchers)
                .HasForeignKey(d => d.VoucherId)
                .HasConstraintName("FK_Order_Voucher");
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.ToTable("OrderItem");

            entity.HasOne(d => d.Book).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.BookId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK_OrderItem_Book");

            entity.HasOne(d => d.Discount).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.DiscountId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK_OrderItem_Discount");

            entity.HasOne(d => d.Membership).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.MembershipId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK_OrderItem_Membership");

            entity.HasOne(d => d.Order).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_OrderItem_Order");

            entity.HasOne(d => d.TicketType).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.TicketTypeId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK_OrderItem_TicketType");

            entity.HasOne(d => d.Voucher).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.VoucherId)
                .OnDelete(DeleteBehavior.SetNull)
                .HasConstraintName("FK_OrderItem_Voucher");
        });

        modelBuilder.Entity<Recommendation>(entity =>
        {
            entity.ToTable("Recommendation");

            entity.HasOne(d => d.Book).WithMany(p => p.Recommendations)
                .HasForeignKey(d => d.BookId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Recommendation_Book");

            entity.HasOne(d => d.Member).WithMany(p => p.Recommendations)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Recommendation_Member");
        });

        modelBuilder.Entity<Ticket>(entity =>
        {
            entity.ToTable("Ticket");

            entity.Property(e => e.PurchasedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Member).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ticket_Member");

            entity.HasOne(d => d.OrderItem).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.OrderItemId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ticket_OrderItem");

            entity.HasOne(d => d.TicketType).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.TicketTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ticket_TicketType");
        });

        modelBuilder.Entity<TicketType>(entity =>
        {
            entity.ToTable("TicketType");

            entity.Property(e => e.Name).HasMaxLength(100);
            entity.Property(e => e.Price).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.Event).WithMany(p => p.TicketTypes)
                .HasForeignKey(d => d.EventId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TicketType_Event");
        });

        modelBuilder.Entity<TicketTypeTransaction>(entity =>
        {
            entity.ToTable("TicketTypeTransaction");

            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.TicketType).WithMany(p => p.TicketTypeTransactions)
                .HasForeignKey(d => d.TicketTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TicketTypeTransaction_TicketType");

            entity.HasOne(d => d.User).WithMany(p => p.TicketTypeTransactions)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_TicketTypeTransaction_User");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("User");

            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.FirstName).HasMaxLength(100);
            entity.Property(e => e.Gender).HasMaxLength(50);
            entity.Property(e => e.LastName).HasMaxLength(100);
            entity.Property(e => e.Password).HasMaxLength(255);
        });

        modelBuilder.Entity<UserBookClub>(entity =>
        {
            entity.ToTable("UserBookClub");

            entity.HasOne(d => d.Member).WithMany(p => p.UserBookClubs)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserBookClub_Member");
        });

        modelBuilder.Entity<UserBookClubTransaction>(entity =>
        {
            entity.ToTable("UserBookClubTransaction");

            entity.Property(e => e.CreatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.BookTransaction).WithMany(p => p.UserBookClubTransactions)
                .HasForeignKey(d => d.BookTransactionId)
                .HasConstraintName("FK_UserBookClubTransaction_BookTransaction");

            entity.HasOne(d => d.OrderItem).WithMany(p => p.UserBookClubTransactions)
                .HasForeignKey(d => d.OrderItemId)
                .HasConstraintName("FK_UserBookClubTransaction_OrderItem");

            entity.HasOne(d => d.UserBookClub).WithMany(p => p.UserBookClubTransactions)
                .HasForeignKey(d => d.UserBookClubId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserBookClubTransaction_UserBookClub");
        });

        modelBuilder.Entity<Voucher>(entity =>
        {
            entity.ToTable("Voucher");

            entity.Property(e => e.Code)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.ExpirationDate).HasColumnType("datetime");
            entity.Property(e => e.PurchasedAt).HasColumnType("datetime");
            entity.Property(e => e.Value).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.PurchasedByMember).WithMany(p => p.Vouchers)
                .HasForeignKey(d => d.PurchasedByMemberId)
                .HasConstraintName("FK_Voucher_Member");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
