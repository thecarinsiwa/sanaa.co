import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Address } from './address.entity';

@Injectable()
export class AddressesService extends CrudService<Address> {
  constructor(
    @InjectRepository(Address)
    repository: Repository<Address>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["city","recipientName"] as (keyof Address & string)[];
  }
}
