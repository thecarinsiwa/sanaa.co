import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { ProductVariant } from './product-variant.entity';

@Injectable()
export class ProductVariantsService extends CrudService<ProductVariant> {
  constructor(
    @InjectRepository(ProductVariant)
    repository: Repository<ProductVariant>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["name","sku","color","size"] as (keyof ProductVariant & string)[];
  }
}
