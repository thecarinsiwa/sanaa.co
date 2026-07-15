import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Quote } from './quote.entity';

@Injectable()
export class QuotesService extends CrudService<Quote> {
  constructor(
    @InjectRepository(Quote)
    repository: Repository<Quote>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["quoteNumber"] as (keyof Quote & string)[];
  }
}
