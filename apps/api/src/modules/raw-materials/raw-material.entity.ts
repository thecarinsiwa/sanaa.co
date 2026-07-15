import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Supplier } from '../suppliers/supplier.entity';

@Entity('raw_materials')
export class RawMaterial extends BaseEntity {
  @Column({ type: 'varchar', length: 80 })
  code!: string;

  @Column({ type: 'varchar', length: 200 })
  name!: string;

  @Column({ type: 'varchar', length: 20, default: 'm' })
  unit!: string;

  @Column({ type: 'text', nullable: true })
  description?: string | null;

  @Column({
    name: 'reorder_level',
    type: 'decimal',
    precision: 14,
    scale: 3,
    default: 0,
  })
  reorderLevel!: string;

  @Column({
    name: 'default_supplier_id',
    type: 'char',
    length: 36,
    nullable: true,
  })
  defaultSupplierId?: string | null;

  @ManyToOne(() => Supplier, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'default_supplier_id' })
  defaultSupplier?: Supplier | null;
}
