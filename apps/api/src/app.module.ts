import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DatabaseModule } from './database/database.module';
import { HealthModule } from './health/health.module';
import { AddressesModule } from './modules/addresses/addresses.module';
import { CartItemsModule } from './modules/cart-items/cart-items.module';
import { CartsModule } from './modules/carts/carts.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { OrderItemsModule } from './modules/order-items/order-items.module';
import { OrdersModule } from './modules/orders/orders.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { ProductVariantsModule } from './modules/product-variants/product-variants.module';
import { ProductsModule } from './modules/products/products.module';
import { QuotesModule } from './modules/quotes/quotes.module';
import { RawMaterialsModule } from './modules/raw-materials/raw-materials.module';
import { ShipmentsModule } from './modules/shipments/shipments.module';
import { SubcategoriesModule } from './modules/subcategories/subcategories.module';
import { SuppliersModule } from './modules/suppliers/suppliers.module';
import { UsersModule } from './modules/users/users.module';
import { WarehousesModule } from './modules/warehouses/warehouses.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    DatabaseModule,
    HealthModule,
    UsersModule,
    AddressesModule,
    CategoriesModule,
    SubcategoriesModule,
    ProductsModule,
    ProductVariantsModule,
    CartsModule,
    CartItemsModule,
    OrdersModule,
    OrderItemsModule,
    PaymentsModule,
    ShipmentsModule,
    QuotesModule,
    SuppliersModule,
    RawMaterialsModule,
    WarehousesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
