import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Supplier } from './supplier.entity';

@Injectable()
export class SuppliersService extends CrudService<Supplier> {
  constructor(
    @InjectRepository(Supplier)
    repository: Repository<Supplier>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["companyName","email"] as (keyof Supplier & string)[];
  }
}
