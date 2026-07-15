import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Shipment } from './shipment.entity';

@Injectable()
export class ShipmentsService extends CrudService<Shipment> {
  constructor(
    @InjectRepository(Shipment)
    repository: Repository<Shipment>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["trackingNumber","carrier"] as (keyof Shipment & string)[];
  }
}
