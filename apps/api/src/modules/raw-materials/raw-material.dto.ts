import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateRawMaterialDto {
  @ApiProperty()
  @IsString()
  code!: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiPropertyOptional({ example: 'm' })
  @IsOptional()
  @IsString()
  unit?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  reorderLevel?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  defaultSupplierId?: string;
}

export class UpdateRawMaterialDto extends PartialType(CreateRawMaterialDto) {}
