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
import { CreateCartItemDto, UpdateCartItemDto } from './cart-item.dto';
import { CartItem } from './cart-item.entity';
import { CartItemsService } from './cart-items.service';

@ApiTags('cart-items')
@Controller('cart-items')
export class CartItemsController {
  constructor(private readonly service: CartItemsService) {}

  @Get()
  @ApiOperation({ summary: 'List cart-items' })
  @ApiOkResponse({ description: 'Paginated list' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get CartItem by id' })
  @ApiOkResponse({ type: CartItem })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create CartItem' })
  @ApiCreatedResponse({ type: CartItem })
  create(@Body() dto: CreateCartItemDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update CartItem' })
  @ApiOkResponse({ type: CartItem })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCartItemDto,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft-delete CartItem' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.remove(id);
  }
}
