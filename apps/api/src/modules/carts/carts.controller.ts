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
import { CreateCartDto, UpdateCartDto } from './cart.dto';
import { Cart } from './cart.entity';
import { CartsService } from './carts.service';

@ApiTags('carts')
@Controller('carts')
export class CartsController {
  constructor(private readonly service: CartsService) {}

  @Get()
  @ApiOperation({ summary: 'List carts' })
  @ApiOkResponse({ description: 'Paginated list' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get Cart by id' })
  @ApiOkResponse({ type: Cart })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create Cart' })
  @ApiCreatedResponse({ type: Cart })
  create(@Body() dto: CreateCartDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update Cart' })
  @ApiOkResponse({ type: Cart })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCartDto,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft-delete Cart' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.remove(id);
  }
}
