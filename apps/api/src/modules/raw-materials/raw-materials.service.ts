import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { RawMaterial } from './raw-material.entity';

@Injectable()
export class RawMaterialsService extends CrudService<RawMaterial> {
  constructor(
    @InjectRepository(RawMaterial)
    repository: Repository<RawMaterial>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ["code","name"] as (keyof RawMaterial & string)[];
  }
}
