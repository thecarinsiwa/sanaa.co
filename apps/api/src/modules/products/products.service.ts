import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Product } from './product.entity';

@Injectable()
export class ProductsService extends CrudService<Product> {
  constructor(
    @InjectRepository(Product)
    repository: Repository<Product>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["name","slug","sku"] as (keyof Product & string)[];
  }
}
