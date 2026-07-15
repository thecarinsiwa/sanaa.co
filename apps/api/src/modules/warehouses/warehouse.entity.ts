import { Column, Entity } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';

@Entity('warehouses')
export class Warehouse extends BaseEntity {
  @Column({ type: 'varchar', length: 40 })
  code!: string;

  @Column({ type: 'varchar', length: 150 })
  name!: string;

  @Column({ type: 'text', nullable: true })
  address?: string | null;

  @Column({ name: 'is_default', type: 'tinyint', width: 1, default: 0 })
  isDefault!: boolean;

  @Column({ name: 'is_active', type: 'tinyint', width: 1, default: 1 })
  isActive!: boolean;
}
