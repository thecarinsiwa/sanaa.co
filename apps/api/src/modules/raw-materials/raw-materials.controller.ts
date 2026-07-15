import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { PaginationQueryDto } from '../../common/dto/pagination.dto';
import { CreateRawMaterialDto, UpdateRawMaterialDto } from './raw-material.dto';
import { RawMaterial } from './raw-material.entity';
import { RawMaterialsService } from './raw-materials.service';

@ApiTags('raw-materials')
@Controller('raw-materials')
export class RawMaterialsController {
  constructor(private readonly service: RawMaterialsService) {}

  @Get()
  @ApiOperation({ summary: 'List raw-materials' })
  @ApiOkResponse({ description: 'Paginated list' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get RawMaterial by id' })
  @ApiOkResponse({ type: RawMaterial })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create RawMaterial' })
  @ApiCreatedResponse({ type: RawMaterial })
  create(@Body() dto: CreateRawMaterialDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update RawMaterial' })
  @ApiOkResponse({ type: RawMaterial })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateRawMaterialDto,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft-delete RawMaterial' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.remove(id);
  }
}
