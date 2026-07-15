import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Cart } from './cart.entity';

@Injectable()
export class CartsService extends CrudService<Cart> {
  constructor(
    @InjectRepository(Cart)
    repository: Repository<Cart>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["sessionToken"] as (keyof Cart & string)[];
  }
}
