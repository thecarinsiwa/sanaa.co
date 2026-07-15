import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateCartItemDto {
  @ApiProperty()
  @IsUUID()
  cartId!: string;

  @ApiProperty()
  @IsUUID()
  productId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  variantId?: string;

  @ApiProperty({ example: '1' })
  @IsString()
  quantity!: string;

  @ApiProperty({ example: '49.99' })
  @IsString()
  unitPrice!: string;
}

export class UpdateCartItemDto extends PartialType(CreateCartItemDto) {}
