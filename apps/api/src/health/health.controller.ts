import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { HealthCheckDto } from './health.dto';

@ApiTags('health')
@Controller('health')
export class HealthController {
  @Get()
  @ApiOperation({ summary: 'Health check' })
  @ApiOkResponse({ type: HealthCheckDto, description: 'Service is healthy' })
  check(): HealthCheckDto {
    return {
      status: 'ok',
      service: 'sanaa-api',
      timestamp: new Date().toISOString(),
    };
  }
}
