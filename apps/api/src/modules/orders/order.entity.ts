import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { User } from '../users/user.entity';
import { Cart } from '../carts/cart.entity';

export enum OrderStatus {
  DRAFT = 'draft',
  PENDING = 'pending',
  PAID = 'paid',
  IN_PRODUCTION = 'in_production',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
}

@Entity('orders')
export class Order extends BaseEntity {
  @Column({ name: 'order_number', type: 'varchar', length: 40 })
  orderNumber!: string;

  @Column({ name: 'user_id', type: 'char', length: 36, nullable: true })
  userId?: string | null;

  @ManyToOne(() => User, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'user_id' })
  user?: User | null;

  @Column({ name: 'cart_id', type: 'char', length: 36, nullable: true })
  cartId?: string | null;

  @ManyToOne(() => Cart, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'cart_id' })
  cart?: Cart | null;

  @Column({ name: 'quote_id', type: 'char', length: 36, nullable: true })
  quoteId?: string | null;

  @Column({
    name: 'shipping_address_id',
    type: 'char',
    length: 36,
    nullable: true,
  })
  shippingAddressId?: string | null;

  @Column({
    name: 'billing_address_id',
    type: 'char',
    length: 36,
    nullable: true,
  })
  billingAddressId?: string | null;

  @Column({
    type: 'enum',
    enum: OrderStatus,
    default: OrderStatus.DRAFT,
  })
  status!: OrderStatus;

  @Column({
    name: 'amount_excl_tax',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  amountExclTax!: string;

  @Column({
    name: 'tax_amount',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  taxAmount!: string;

  @Column({
    name: 'shipping_amount',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  shippingAmount!: string;

  @Column({
    name: 'discount_amount',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  discountAmount!: string;

  @Column({
    name: 'amount_incl_tax',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  amountInclTax!: string;

  @Column({ type: 'char', length: 3, default: 'USD' })
  currency!: string;

  @Column({ name: 'shipping_address_snapshot', type: 'json', nullable: true })
  shippingAddressSnapshot?: Record<string, unknown> | null;

  @Column({ name: 'billing_address_snapshot', type: 'json', nullable: true })
  billingAddressSnapshot?: Record<string, unknown> | null;

  @Column({ type: 'text', nullable: true })
  notes?: string | null;

  @Column({
    name: 'placed_at',
    type: 'datetime',
    precision: 6,
    nullable: true,
  })
  placedAt?: Date | null;
}
