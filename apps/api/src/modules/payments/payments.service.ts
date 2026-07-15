import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Payment } from './payment.entity';

@Injectable()
export class PaymentsService extends CrudService<Payment> {
  constructor(
    @InjectRepository(Payment)
    repository: Repository<Payment>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["externalReference"] as (keyof Payment & string)[];
  }
}
