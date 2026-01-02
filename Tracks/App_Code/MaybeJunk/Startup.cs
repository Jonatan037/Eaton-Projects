using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(NCR.Startup))]
namespace NCR
{
    public partial class Startup {
        public void Configuration(IAppBuilder app) {
            ConfigureAuth(app);
        }
    }
}
