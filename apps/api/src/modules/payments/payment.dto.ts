import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { PaymentMethod, PaymentStatus } from './payment.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreatePaymentDto {
  @ApiProperty()
  @IsUUID()
  orderId!: string;

  @ApiProperty({ example: '49.99' })
  @IsString()
  amount!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional({ enum: PaymentMethod })
  @IsOptional()
  @IsEnum(PaymentMethod)
  method?: PaymentMethod;

  @ApiPropertyOptional({ enum: PaymentStatus })
  @IsOptional()
  @IsEnum(PaymentStatus)
  status?: PaymentStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  provider?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  externalReference?: string;
}

export class UpdatePaymentDto extends PartialType(CreatePaymentDto) {}
