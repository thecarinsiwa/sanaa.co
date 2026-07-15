import { ApiProperty } from '@nestjs/swagger';

export class HealthCheckDto {
  @ApiProperty({ example: 'ok' })
  status!: string;

  @ApiProperty({ example: 'sanaa-api' })
  service!: string;

  @ApiProperty({ example: '2026-07-15T13:00:00.000Z' })
  timestamp!: string;
}
