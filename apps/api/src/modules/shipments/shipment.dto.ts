import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { ShipmentStatus } from './shipment.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateShipmentDto {
  @ApiProperty()
  @IsUUID()
  orderId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  carrier?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  trackingNumber?: string;

  @ApiPropertyOptional({ enum: ShipmentStatus })
  @IsOptional()
  @IsEnum(ShipmentStatus)
  status?: ShipmentStatus;
}

export class UpdateShipmentDto extends PartialType(CreateShipmentDto) {}
