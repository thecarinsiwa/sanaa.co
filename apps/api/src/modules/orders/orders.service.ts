import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Order } from './order.entity';

@Injectable()
export class OrdersService extends CrudService<Order> {
  constructor(
    @InjectRepository(Order)
    repository: Repository<Order>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["orderNumber"] as (keyof Order & string)[];
  }
}
