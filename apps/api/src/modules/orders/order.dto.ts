import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { OrderStatus } from './order.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateOrderDto {
  @ApiProperty({ example: 'ORD-1001' })
  @IsString()
  orderNumber!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  cartId?: string;

  @ApiPropertyOptional({ enum: OrderStatus })
  @IsOptional()
  @IsEnum(OrderStatus)
  status?: OrderStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  amountExclTax?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  taxAmount?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  shippingAmount?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  discountAmount?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  amountInclTax?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;
}

export class UpdateOrderDto extends PartialType(CreateOrderDto) {}
