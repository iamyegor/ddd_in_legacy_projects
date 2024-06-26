﻿using System.Collections.Generic;
using PackageDelivery.Common;
using PackageDeliveryNew.Deliveries;
using PackageDeliveryNew.Infrastructure;

namespace PackageDelivery.DeliveryNew
{
    public class EditProductViewModel : ViewModel
    {
        public IReadOnlyList<Product> Products { get; }
        public Product SelectedProduct { get; set; }
        public Command<Product> OkCommand { get; }
        public Command CancelCommand { get; }

        public override string Caption => "Change product";

        public EditProductViewModel()
        {
            Products = new ProductRepository().GetAll();

            OkCommand = new Command<Product>(x => x != null, _ => DialogResult = true);
            CancelCommand = new Command(() => DialogResult = false);
        }
    }
}
