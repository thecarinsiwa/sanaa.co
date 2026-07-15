import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { Category } from './category.entity';

@Injectable()
export class CategoriesService extends CrudService<Category> {
  constructor(
    @InjectRepository(Category)
    repository: Repository<Category>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["name","slug"] as (keyof Category & string)[];
  }
}
