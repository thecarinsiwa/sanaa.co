import { ApiProperty } from '@nestjs/swagger';

export class AppInfoDto {
  @ApiProperty({ example: 'Sanaa.co API' })
  name!: string;

  @ApiProperty({ example: '0.0.1' })
  version!: string;

  @ApiProperty({ example: 'ok' })
  status!: string;
}
