using EasyNetQ;
using ZemljaSlova.Model.Messages;

var bus = RabbitHutch.CreateBus("host=localhost");

await bus.PubSub.SubscribeAsync<MembershipCreated>("membership_mail", msg => 
{
    Console.WriteLine($"Membership with id:{msg.Membership.Id} created for member with id:{msg.Membership.MemberId}");
});

Console.WriteLine("Listening for membership-created messages");
Console.ReadLine();