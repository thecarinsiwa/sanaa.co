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
import { CreateOrderItemDto, UpdateOrderItemDto } from './order-item.dto';
import { OrderItem } from './order-item.entity';
import { OrderItemsService } from './order-items.service';

@ApiTags('order-items')
@Controller('order-items')
export class OrderItemsController {
  constructor(private readonly service: OrderItemsService) {}

  @Get()
  @ApiOperation({ summary: 'List order-items' })
  @ApiOkResponse({ description: 'Paginated list' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get OrderItem by id' })
  @ApiOkResponse({ type: OrderItem })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create OrderItem' })
  @ApiCreatedResponse({ type: OrderItem })
  create(@Body() dto: CreateOrderItemDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update OrderItem' })
  @ApiOkResponse({ type: OrderItem })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateOrderItemDto,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft-delete OrderItem' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.remove(id);
  }
}
