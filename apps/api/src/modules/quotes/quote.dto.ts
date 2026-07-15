import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { QuoteStatus } from './quote.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateQuoteDto {
  @ApiProperty({ example: 'QT-1001' })
  @IsString()
  quoteNumber!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  salesRepId?: string;

  @ApiPropertyOptional({ enum: QuoteStatus })
  @IsOptional()
  @IsEnum(QuoteStatus)
  status?: QuoteStatus;

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

export class UpdateQuoteDto extends PartialType(CreateQuoteDto) {}
