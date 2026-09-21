
using System;
using System.Threading.Tasks;
using Grpc.Net.Client;
using Hipstershop;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Hosting;
using Xunit;
using static Hipstershop.CartService;

namespace cartservice.tests
{
    public class CartServiceTests
    {
        private readonly IHostBuilder _host;

        public CartServiceTests()
        {
            _host = new HostBuilder().ConfigureWebHost(webBuilder =>
            {
                webBuilder
                    .UseStartup<Startup>()
                    .UseTestServer();
            });
        }

        [Fact]
        public async Task GetItem_NoAddItemBefore_EmptyCartReturned()
        {
            using var server = await _host.StartAsync();
            var httpClient = server.GetTestClient();

            string userId = Guid.NewGuid().ToString();

            var channel = GrpcChannel.ForAddress(httpClient.BaseAddress, new GrpcChannelOptions
            {
                HttpClient = httpClient
            });

            var cartClient = new CartServiceClient(channel);

            var request = new GetCartRequest
            {
                UserId = userId,
            };

            var cart = await cartClient.GetCartAsync(request);
            Assert.NotNull(cart);

            Assert.Equal(new Cart(), cart);
        }

        [Fact]
        public async Task AddItem_ItemExists_Updated()
        {
            using var server = await _host.StartAsync();
            var httpClient = server.GetTestClient();

            string userId = Guid.NewGuid().ToString();

            var channel = GrpcChannel.ForAddress(httpClient.BaseAddress, new GrpcChannelOptions
            {
                HttpClient = httpClient
            });

            var client = new CartServiceClient(channel);
            var request = new AddItemRequest
            {
                UserId = userId,
                Item = new CartItem
                {
                    ProductId = "1",
                    Quantity = 1
                }
            };

            await client.AddItemAsync(request);

            await client.AddItemAsync(request);

            var getCartRequest = new GetCartRequest
            {
                UserId = userId
            };
            var cart = await client.GetCartAsync(getCartRequest);
            Assert.NotNull(cart);
            Assert.Equal(userId, cart.UserId);
            Assert.Single(cart.Items);
            Assert.Equal(2, cart.Items[0].Quantity);

            await client.EmptyCartAsync(new EmptyCartRequest { UserId = userId });
        }

        [Fact]
        public async Task AddItem_New_Inserted()
        {
            using var server = await _host.StartAsync();
            var httpClient = server.GetTestClient();

            string userId = Guid.NewGuid().ToString();

            var channel = GrpcChannel.ForAddress(httpClient.BaseAddress, new GrpcChannelOptions
            {
                HttpClient = httpClient
            });

            var client = new CartServiceClient(channel);

            var request = new AddItemRequest
            {
                UserId = userId,
                Item = new CartItem
                {
                    ProductId = "1",
                    Quantity = 1
                }
            };

            await client.AddItemAsync(request);

            var getCartRequest = new GetCartRequest
            {
                UserId = userId
            };
            var cart = await client.GetCartAsync(getCartRequest);
            Assert.NotNull(cart);
            Assert.Equal(userId, cart.UserId);
            Assert.Single(cart.Items);

            await client.EmptyCartAsync(new EmptyCartRequest { UserId = userId });
            cart = await client.GetCartAsync(getCartRequest);
            Assert.Empty(cart.Items);
        }
    }
}
