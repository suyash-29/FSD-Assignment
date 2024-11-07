﻿using System;
using System.Collections.Generic;

namespace DatabaseFirst_Demo.Models
{
    public partial class Stock
    {
        public int StoreId { get; set; }
        public int ProductId { get; set; }
        public int? Quantity { get; set; }

        public virtual Product1 Product { get; set; } = null!;
        public virtual Store Store { get; set; } = null!;
    }
}
