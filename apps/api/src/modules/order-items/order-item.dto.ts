import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateOrderItemDto {
  @ApiProperty()
  @IsUUID()
  orderId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  productId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  variantId?: string;

  @ApiProperty()
  @IsString()
  label!: string;

  @ApiProperty({ example: '1' })
  @IsString()
  quantity!: string;

  @ApiProperty({ example: '49.99' })
  @IsString()
  unitPrice!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  taxRate?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  discountAmount?: string;

  @ApiProperty({ example: '49.99' })
  @IsString()
  lineTotal!: string;
}

export class UpdateOrderItemDto extends PartialType(CreateOrderItemDto) {}
