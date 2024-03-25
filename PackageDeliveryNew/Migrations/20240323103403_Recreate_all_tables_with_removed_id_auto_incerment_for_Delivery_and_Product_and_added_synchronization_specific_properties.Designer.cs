﻿// <auto-generated />
using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using PackageDeliveryNew.Infrastructure;

#nullable disable

namespace PackageDeliveryNew.Migrations
{
    [DbContext(typeof(ApplicationContext))]
    [Migration("20240323103403_Recreate_all_tables_with_removed_id_auto_incerment_for_Delivery_and_Product_and_added_synchronization_specific_properties")]
    partial class Recreate_all_tables_with_removed_id_auto_incerment_for_Delivery_and_Product_and_added_synchronization_specific_properties
    {
        /// <inheritdoc />
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "8.0.3")
                .HasAnnotation("Relational:MaxIdentifierLength", 128);

            SqlServerModelBuilderExtensions.UseIdentityColumns(modelBuilder);

            modelBuilder.Entity("PackageDeliveryNew.Deliveries.Delivery", b =>
                {
                    b.Property<int>("Id")
                        .HasColumnType("int");

                    b.Property<decimal?>("CostEstimate")
                        .HasColumnType("decimal(18,2)");

                    b.Property<bool>("IsSyncNeeded")
                        .HasColumnType("bit");

                    b.ComplexProperty<Dictionary<string, object>>("Destination", "PackageDeliveryNew.Deliveries.Delivery.Destination#Address", b1 =>
                        {
                            b1.IsRequired();

                            b1.Property<string>("City")
                                .IsRequired()
                                .HasColumnType("nvarchar(max)");

                            b1.Property<string>("State")
                                .IsRequired()
                                .HasColumnType("nvarchar(max)");

                            b1.Property<string>("Street")
                                .IsRequired()
                                .HasColumnType("nvarchar(max)");

                            b1.Property<string>("ZipCode")
                                .IsRequired()
                                .HasColumnType("nvarchar(max)");
                        });

                    b.HasKey("Id");

                    b.ToTable("Deliveries");
                });

            modelBuilder.Entity("PackageDeliveryNew.Deliveries.Product", b =>
                {
                    b.Property<int>("Id")
                        .HasColumnType("int");

                    b.Property<string>("Name")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<double>("WeightInPounds")
                        .HasColumnType("float");

                    b.HasKey("Id");

                    b.ToTable("Products");
                });

            modelBuilder.Entity("PackageDeliveryNew.Infrastructure.Synchronization", b =>
                {
                    b.Property<string>("Name")
                        .HasColumnType("nvarchar(450)");

                    b.Property<bool>("IsSyncRequired")
                        .HasColumnType("bit");

                    b.HasKey("Name");

                    b.ToTable("Synchronization");
                });

            modelBuilder.Entity("PackageDeliveryNew.Deliveries.Delivery", b =>
                {
                    b.OwnsMany("PackageDeliveryNew.Deliveries.ProductLine", "ProductLines", b1 =>
                        {
                            b1.Property<int>("DeliveryId")
                                .HasColumnType("int");

                            b1.Property<int>("Id")
                                .ValueGeneratedOnAdd()
                                .HasColumnType("int");

                            SqlServerPropertyBuilderExtensions.UseIdentityColumn(b1.Property<int>("Id"));

                            b1.Property<int>("Amount")
                                .HasColumnType("int");

                            b1.Property<int>("ProductId")
                                .HasColumnType("int");

                            b1.HasKey("DeliveryId", "Id");

                            b1.HasIndex("ProductId");

                            b1.ToTable("Delivery_ProductLines", (string)null);

                            b1.WithOwner()
                                .HasForeignKey("DeliveryId");

                            b1.HasOne("PackageDeliveryNew.Deliveries.Product", "Product")
                                .WithMany()
                                .HasForeignKey("ProductId")
                                .OnDelete(DeleteBehavior.Cascade)
                                .IsRequired();

                            b1.Navigation("Product");
                        });

                    b.Navigation("ProductLines");
                });
#pragma warning restore 612, 618
        }
    }
}