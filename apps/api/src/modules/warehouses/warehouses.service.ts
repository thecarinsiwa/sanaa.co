import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Warehouse } from './warehouse.entity';

@Injectable()
export class WarehousesService extends CrudService<Warehouse> {
  constructor(
    @InjectRepository(Warehouse)
    repository: Repository<Warehouse>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["code","name"] as (keyof Warehouse & string)[];
  }
}
