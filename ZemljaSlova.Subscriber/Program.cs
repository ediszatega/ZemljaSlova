using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using ZemljaSlova.Subscriber;

Console.WriteLine("_Starting ZemljaSlova Subscriber Service");
Console.WriteLine("_Waiting for RabbitMQ to be ready");

// Wait for RabbitMQ to be ready with retry logic
IConnection? connection = null;
IModel? channel = null;
int maxRetries = 5;
int retryDelayMs = 2000;

string exchangeName = "EmailExchange";
string routingKey = "email_queue";
string queueName = "EmailQueue";

// Wait for RabbitMQ to initialize
Console.WriteLine("_Waiting for RabbitMQ to initialize");
Thread.Sleep(5000);

for (int attempt = 1; attempt <= maxRetries; attempt++)
{
    try
    {
        Console.WriteLine($"_Attempt {attempt}/{maxRetries}: Connecting to RabbitMQ");
        
        var factory = new ConnectionFactory
        {
            HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
            Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
            UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
            Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest",
        };
        factory.ClientProvidedName = "ZemljaSlova Consumer";

        connection = factory.CreateConnection();
        channel = connection.CreateModel();

        channel.ExchangeDeclare(exchangeName, ExchangeType.Direct);
        channel.QueueDeclare(queueName, true, false, false, null);
        channel.QueueBind(queueName, exchangeName, routingKey, null);

        Console.WriteLine("_Successfully connected to RabbitMQ");
        break;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"_Connection attempt {attempt} failed: {ex.Message}");
        
        if (attempt < maxRetries)
        {
            Console.WriteLine($"_Waiting {retryDelayMs/1000} seconds before retry");
            Thread.Sleep(retryDelayMs);
        }
        else
        {
            Console.WriteLine("_Failed to connect to RabbitMQ after all retry attempts");
            Console.WriteLine("_Press any key to exit");
            Console.ReadKey();
            return;
        }
    }
}

var consumer = new EventingBasicConsumer(channel);

consumer.Received += (sender, args) =>
{
    var body = args.Body.ToArray();
    string message = Encoding.UTF8.GetString(body);

    Console.WriteLine($"_Message received: {message}");
    
    EmailService emailService = new EmailService();
    emailService.SendEmail(message);

    channel?.BasicAck(args.DeliveryTag, false);
};

channel.BasicConsume(queueName, false, consumer);

Console.WriteLine("Waiting for email messages.");

using var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) => {
    e.Cancel = true;
    cts.Cancel();
};

try
{
    await Task.Delay(Timeout.Infinite, cts.Token);
}
catch (OperationCanceledException)
{
    Console.WriteLine("Shutdown signal received");
}

Console.WriteLine("_Shutting down subscriber service");
channel?.Close();
connection?.Close();
Console.WriteLine("_Subscriber service stopped");