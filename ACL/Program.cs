using ACL.ConnectionStrings;
using ACL.Synchronizers.Delivery;
using ACL.Synchronizers.Delivery.OutboxSynchronizers;
using ACL.Synchronizers.Delivery.Repositories;
using ACL.Synchronizers.Product;
using ACL.Synchronizers.Product.Repositories;
using ACL.Workers;

var builder = Host.CreateApplicationBuilder(args);
builder.Services.AddHostedService<ProductSynchronizerWorker>();
builder.Services.AddHostedService<DeliverySynchronizerWorker>();
builder.Services.AddHostedService<OutboxWorker>();

builder.Services.AddTransient<LegacyProductSynchronizer>();
builder.Services.AddTransient<LegacyOutboxProductSynchronizer>();
builder.Services.AddTransient<LegacyDeliveryRepository>();
builder.Services.AddTransient<LegacyOutboxRepository>();
builder.Services.AddTransient<LegacyOutboxDeliverySynchronizer>();
builder.Services.AddTransient<LegacyDeliverySynchronizer>();
builder.Services.AddTransient<BubbleDeliverySynchronizer>();
builder.Services.AddTransient<BubbleOutboxDeliverySynchronizer>();
builder.Services.AddTransient<BubbleOutboxRepository>();
builder.Services.AddTransient<BubbleProductRepository>();
builder.Services.AddTransient<BubbleDeliveryRepository>();

builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

LegacyConnectionString.Value = builder.Configuration.GetConnectionString("Legacy")!;
BubbleConnectionString.Value = builder.Configuration.GetConnectionString("Bubble")!;

var host = builder.Build();
host.Run();
