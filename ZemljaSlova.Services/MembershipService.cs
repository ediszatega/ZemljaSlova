using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using ZemljaSlova.Model.Requests;
using ZemljaSlova.Model.SearchObjects;
using ZemljaSlova.Services.Database;
using EasyNetQ;
using ZemljaSlova.Model.Messages;

namespace ZemljaSlova.Services
{
    public class MembershipService : BaseCRUDService<Model.Membership, MembershipSearchObject, Database.Membership, MembershipInsertRequest, MembershipUpdateRequest>, IMembershipService
    {
        public MembershipService(_200036Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override void AfterInsert(MembershipInsertRequest request, Database.Membership entity)
        {
            base.AfterInsert(request, entity);

            // publish membership-created evt
            var bus = RabbitHutch.CreateBus("host=localhost");

            MembershipCreated message = new MembershipCreated { Membership = Mapper.Map<Model.Membership>(entity) };
            bus.PubSub.Publish(message);
        }
    }
}
