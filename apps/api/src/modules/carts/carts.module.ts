import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CartsController } from './carts.controller';
import { Cart } from './cart.entity';
import { CartsService } from './carts.service';

@Module({
  imports: [TypeOrmModule.forFeature([Cart])],
  controllers: [CartsController],
  providers: [CartsService],
  exports: [CartsService],
})
export class CartsModule {}
