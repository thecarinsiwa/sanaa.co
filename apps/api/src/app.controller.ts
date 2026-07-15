import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AppInfoDto } from './app.dto';
import { AppService } from './app.service';

@ApiTags('root')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  @ApiOperation({ summary: 'API information' })
  @ApiOkResponse({ type: AppInfoDto, description: 'Basic API metadata' })
  getRoot(): AppInfoDto {
    return this.appService.getInfo();
  }
}
