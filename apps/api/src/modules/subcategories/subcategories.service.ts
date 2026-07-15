import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Subcategory } from './subcategory.entity';

@Injectable()
export class SubcategoriesService extends CrudService<Subcategory> {
  constructor(
    @InjectRepository(Subcategory)
    repository: Repository<Subcategory>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["name","slug"] as (keyof Subcategory & string)[];
  }
}
