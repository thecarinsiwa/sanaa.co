import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { User } from './user.entity';

@Injectable()
export class UsersService extends CrudService<User> {
  constructor(
    @InjectRepository(User)
    repository: Repository<User>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["email","lastName","firstName"] as (keyof User & string)[];
  }
}
