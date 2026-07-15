import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductVariantsController } from './product-variants.controller';
import { ProductVariant } from './product-variant.entity';
import { ProductVariantsService } from './product-variants.service';

@Module({
  imports: [TypeOrmModule.forFeature([ProductVariant])],
  controllers: [ProductVariantsController],
  providers: [ProductVariantsService],
  exports: [ProductVariantsService],
})
export class ProductVariantsModule {}
