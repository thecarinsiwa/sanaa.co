import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { CartItem } from './cart-item.entity';

@Injectable()
export class CartItemsService extends CrudService<CartItem> {
  constructor(
    @InjectRepository(CartItem)
    repository: Repository<CartItem>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return [] as (keyof CartItem & string)[];
  }
}
