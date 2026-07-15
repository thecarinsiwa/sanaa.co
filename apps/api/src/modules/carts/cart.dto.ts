import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { CartStatus } from './cart.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateCartDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sessionToken?: string;

  @ApiPropertyOptional({ example: 'USD' })
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional({ enum: CartStatus })
  @IsOptional()
  @IsEnum(CartStatus)
  status?: CartStatus;
}

export class UpdateCartDto extends PartialType(CreateCartDto) {}
