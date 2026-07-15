import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { OrderItem } from './order-item.entity';

@Injectable()
export class OrderItemsService extends CrudService<OrderItem> {
  constructor(
    @InjectRepository(OrderItem)
    repository: Repository<OrderItem>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["label"] as (keyof OrderItem & string)[];
  }
}
