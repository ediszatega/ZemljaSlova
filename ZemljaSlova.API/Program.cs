using Mapster;
using Microsoft.EntityFrameworkCore;
using ZemljaSlova.API.Filters;
using ZemljaSlova.Services;
using ZemljaSlova.Services.Database;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
var builder = WebApplication.CreateBuilder(args);

// Kestrel configuration to accept larger request bodies
builder.Services.Configure<Microsoft.AspNetCore.Server.Kestrel.Core.KestrelServerOptions>(options =>
{
    options.Limits.MaxRequestBodySize = 15 * 1024 * 1024; // 15 MB
});

// Add services to the container.
builder.Services.AddTransient<IBookTransactionService, BookTransactionService>();
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
builder.Services.AddTransient<IBookClubPointsService, BookClubPointsService>();
builder.Services.AddTransient<IVoucherService, VoucherService>();
builder.Services.AddTransient<IReportingService, ReportingService>();
builder.Services.AddTransient<IRecommendationService, RecommendationService>();
builder.Services.AddScoped<IRabbitMQProducer, RabbitMQProducer>();

builder.Services.AddAuthentication(
    JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options => {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey=true,
            IssuerSigningKey=new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration.GetSection("AppSettings:Token").Value)),
            ValidateIssuer = false,
            ValidateAudience = false
        };
    });

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});

// Form configuration options for file uploads
builder.Services.Configure<Microsoft.AspNetCore.Http.Features.FormOptions>(options =>
{
    options.MultipartBodyLengthLimit = 15 * 1024 * 1024; // 15 MB
    options.ValueLengthLimit = int.MaxValue;
    options.ValueCountLimit = int.MaxValue;
    options.KeyLengthLimit = int.MaxValue;
    options.MultipartHeadersLengthLimit = int.MaxValue;
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<_200036Context>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();
TypeAdapterConfig.GlobalSettings.Default.PreserveReference(true);
TypeAdapterConfig.GlobalSettings.Default.IgnoreNullValues(true);

// Configure Stripe globally
Stripe.StripeConfiguration.ApiKey = builder.Configuration["Stripe:SecretKey"];

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<_200036Context>();
    
    var sqlPath = Path.Combine(AppContext.BaseDirectory, "script.sql");
    if (File.Exists(sqlPath))
    {
        var sql = File.ReadAllText(sqlPath);
        context.Database.ExecuteSqlRaw(sql);
    }
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
