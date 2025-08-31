namespace ZemljaSlova.Services
{
    public interface IRabbitMQProducer
    {
        void SendMessage<T>(T message);
    }
}
