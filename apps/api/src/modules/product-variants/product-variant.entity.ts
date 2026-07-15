import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Product } from '../products/product.entity';

@Entity('product_variants')
export class ProductVariant extends BaseEntity {
  @Column({ name: 'product_id', type: 'char', length: 36 })
  productId!: string;

  @ManyToOne(() => Product, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'product_id' })
  product?: Product;

  @Column({ type: 'varchar', length: 80, nullable: true })
  sku?: string | null;

  @Column({ type: 'varchar', length: 150 })
  name!: string;

  @Column({ type: 'varchar', length: 40, nullable: true })
  size?: string | null;

  @Column({ type: 'varchar', length: 80, nullable: true })
  color?: string | null;

  @Column({ type: 'varchar', length: 64, nullable: true })
  barcode?: string | null;

  @Column({ type: 'decimal', precision: 14, scale: 2, nullable: true })
  price?: string | null;

  @Column({
    name: 'weight_grams',
    type: 'decimal',
    precision: 12,
    scale: 3,
    nullable: true,
  })
  weightGrams?: string | null;

  @Column({ name: 'is_default', type: 'tinyint', width: 1, default: 0 })
  isDefault!: boolean;

  @Column({ name: 'is_active', type: 'tinyint', width: 1, default: 1 })
  isActive!: boolean;

  @Column({ type: 'json', nullable: true })
  metadata?: Record<string, unknown> | null;
}
