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
import { CreateProductVariantDto, UpdateProductVariantDto } from './product-variant.dto';
import { ProductVariant } from './product-variant.entity';
import { ProductVariantsService } from './product-variants.service';

@ApiTags('product-variants')
@Controller('product-variants')
export class ProductVariantsController {
  constructor(private readonly service: ProductVariantsService) {}

  @Get()
  @ApiOperation({ summary: 'List product-variants' })
  @ApiOkResponse({ description: 'Paginated list' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get ProductVariant by id' })
  @ApiOkResponse({ type: ProductVariant })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create ProductVariant' })
  @ApiCreatedResponse({ type: ProductVariant })
  create(@Body() dto: CreateProductVariantDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update ProductVariant' })
  @ApiOkResponse({ type: ProductVariant })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateProductVariantDto,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft-delete ProductVariant' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.remove(id);
  }
}
