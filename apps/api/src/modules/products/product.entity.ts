import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Category } from '../categories/category.entity';
import { Subcategory } from '../subcategories/subcategory.entity';

export enum ProductType {
  STANDARD = 'standard',
  CUSTOM = 'custom',
  SEMI_CUSTOM = 'semi_custom',
}

@Entity('products')
export class Product extends BaseEntity {
  @Column({ name: 'category_id', type: 'char', length: 36, nullable: true })
  categoryId?: string | null;

  @ManyToOne(() => Category, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'category_id' })
  category?: Category | null;

  @Column({ name: 'subcategory_id', type: 'char', length: 36, nullable: true })
  subcategoryId?: string | null;

  @ManyToOne(() => Subcategory, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'subcategory_id' })
  subcategory?: Subcategory | null;

  @Column({ type: 'varchar', length: 80, nullable: true })
  sku?: string | null;

  @Column({ type: 'varchar', length: 255 })
  name!: string;

  @Column({ type: 'varchar', length: 280 })
  slug!: string;

  @Column({ type: 'text', nullable: true })
  description?: string | null;

  @Column({
    name: 'short_description',
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  shortDescription?: string | null;

  @Column({
    name: 'product_type',
    type: 'enum',
    enum: ProductType,
    default: ProductType.STANDARD,
  })
  productType!: ProductType;

  @Column({
    name: 'base_price',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  basePrice!: string;

  @Column({
    name: 'compare_at_price',
    type: 'decimal',
    precision: 14,
    scale: 2,
    nullable: true,
  })
  compareAtPrice?: string | null;

  @Column({ type: 'char', length: 3, default: 'USD' })
  currency!: string;

  @Column({
    name: 'weight_grams',
    type: 'decimal',
    precision: 12,
    scale: 3,
    nullable: true,
  })
  weightGrams?: string | null;

  @Column({ name: 'is_featured', type: 'tinyint', width: 1, default: 0 })
  isFeatured!: boolean;

  @Column({ name: 'is_active', type: 'tinyint', width: 1, default: 1 })
  isActive!: boolean;

  @Column({ type: 'json', nullable: true })
  metadata?: Record<string, unknown> | null;
}
