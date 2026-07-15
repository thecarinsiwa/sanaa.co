import { NotFoundException } from '@nestjs/common';
import {
  DeepPartial,
  FindOptionsOrder,
  FindOptionsWhere,
  Like,
  ObjectLiteral,
  Repository,
} from 'typeorm';
import { PaginationQueryDto } from '../dto/pagination.dto';

export abstract class CrudService<
  T extends ObjectLiteral & { id: string; createdAt?: Date },
> {
  protected constructor(protected readonly repository: Repository<T>) {}

  /** Override in subclasses to enable `?search=` filtering. */
  protected get searchFields(): (keyof T & string)[] {
    return [];
  }

  async findAll(query: PaginationQueryDto = {}) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const where = this.buildSearchWhere(query.search);

    const [data, total] = await this.repository.findAndCount({
      where,
      order: { createdAt: 'DESC' } as FindOptionsOrder<T>,
      skip,
      take: limit,
    });

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  async findOne(id: string): Promise<T> {
    const entity = await this.repository.findOne({
      where: { id } as FindOptionsWhere<T>,
    });
    if (!entity) {
      throw new NotFoundException(`Resource ${id} not found`);
    }
    return entity;
  }

  async create(dto: DeepPartial<T>): Promise<T> {
    const entity = this.repository.create(dto);
    return this.repository.save(entity);
  }

  async update(id: string, dto: DeepPartial<T>): Promise<T> {
    const entity = await this.findOne(id);
    Object.assign(entity, dto);
    return this.repository.save(entity);
  }

  async remove(id: string): Promise<{ id: string; deleted: true }> {
    await this.findOne(id);
    await this.repository.softDelete(id);
    return { id, deleted: true };
  }

  private buildSearchWhere(
    search?: string,
  ): FindOptionsWhere<T>[] | undefined {
    if (!search?.trim() || this.searchFields.length === 0) {
      return undefined;
    }
    const pattern = `%${search.trim()}%`;
    return this.searchFields.map(
      (field) =>
        ({
          [field]: Like(pattern),
        }) as FindOptionsWhere<T>,
    );
  }
}
