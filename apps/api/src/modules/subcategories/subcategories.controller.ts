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
import { CreateSubcategoryDto, UpdateSubcategoryDto } from './subcategory.dto';
import { Subcategory } from './subcategory.entity';
import { SubcategoriesService } from './subcategories.service';

@ApiTags('subcategories')
@Controller('subcategories')
export class SubcategoriesController {
  constructor(private readonly service: SubcategoriesService) {}

  @Get()
  @ApiOperation({ summary: 'List subcategories' })
  @ApiOkResponse({ description: 'Paginated list' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get Subcategory by id' })
  @ApiOkResponse({ type: Subcategory })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create Subcategory' })
  @ApiCreatedResponse({ type: Subcategory })
  create(@Body() dto: CreateSubcategoryDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update Subcategory' })
  @ApiOkResponse({ type: Subcategory })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSubcategoryDto,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft-delete Subcategory' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.remove(id);
  }
}
