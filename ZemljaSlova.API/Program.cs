using Mapster;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.API.Filters;
using ZemljaSlova.Services;
using ZemljaSlova.Services.Database;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IBookService, BookService>();
builder.Services.AddTransient<IAuthorService, AuthorService>();
builder.Services.AddTransient<IBookReservationService, BookReservationService>();
builder.Services.AddTransient<IDiscountService, DiscountService>();
builder.Services.AddTransient<IEmployeeService, EmployeeService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IEventService, EventService>();
builder.Services.AddTransient<IFavouriteService, FavouriteService>();
builder.Services.AddTransient<IMemberService, MemberService>();
builder.Services.AddTransient<IMembershipService, MembershipService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IOrderService, OrderService>();
builder.Services.AddTransient<IOrderItemService, OrderItemService>();
builder.Services.AddTransient<ITicketService, TicketService>();
builder.Services.AddTransient<ITicketTypeService, TicketTypeService>();
builder.Services.AddTransient<ITicketTypeTransactionService, TicketTypeTransactionService>();
builder.Services.AddTransient<IUserBookClubService, UserBookClubService>();
builder.Services.AddTransient<IUserBookClubTransactionService, UserBookClubTransactionService>();
builder.Services.AddTransient<IVoucherService, VoucherService>();

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<_200036Context>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
