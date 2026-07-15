import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Order } from '../orders/order.entity';
import { Product } from '../products/product.entity';
import { ProductVariant } from '../product-variants/product-variant.entity';

@Entity('order_items')
export class OrderItem extends BaseEntity {
  @Column({ name: 'order_id', type: 'char', length: 36 })
  orderId!: string;

  @ManyToOne(() => Order, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'order_id' })
  order?: Order;

  @Column({ name: 'product_id', type: 'char', length: 36, nullable: true })
  productId?: string | null;

  @ManyToOne(() => Product, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'product_id' })
  product?: Product | null;

  @Column({ name: 'variant_id', type: 'char', length: 36, nullable: true })
  variantId?: string | null;

  @ManyToOne(() => ProductVariant, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'variant_id' })
  variant?: ProductVariant | null;

  @Column({ name: 'sku_snapshot', type: 'varchar', length: 80, nullable: true })
  skuSnapshot?: string | null;

  @Column({ type: 'varchar', length: 255 })
  label!: string;

  @Column({ type: 'decimal', precision: 14, scale: 3, default: 1 })
  quantity!: string;

  @Column({
    name: 'unit_price',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  unitPrice!: string;

  @Column({
    name: 'tax_rate',
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 0,
  })
  taxRate!: string;

  @Column({
    name: 'discount_amount',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  discountAmount!: string;

  @Column({
    name: 'line_total',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  lineTotal!: string;
}
