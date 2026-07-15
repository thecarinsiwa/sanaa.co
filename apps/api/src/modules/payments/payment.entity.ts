import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Order } from '../orders/order.entity';

export enum PaymentMethod {
  CARD = 'card',
  MOBILE_MONEY = 'mobile_money',
  BANK_TRANSFER = 'bank_transfer',
  CASH = 'cash',
  OTHER = 'other',
}

export enum PaymentStatus {
  PENDING = 'pending',
  SUCCEEDED = 'succeeded',
  FAILED = 'failed',
  REFUNDED = 'refunded',
}

@Entity('payments')
export class Payment extends BaseEntity {
  @Column({ name: 'order_id', type: 'char', length: 36 })
  orderId!: string;

  @ManyToOne(() => Order, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'order_id' })
  order?: Order;

  @Column({ type: 'decimal', precision: 14, scale: 2 })
  amount!: string;

  @Column({ type: 'char', length: 3, default: 'USD' })
  currency!: string;

  @Column({
    type: 'enum',
    enum: PaymentMethod,
    default: PaymentMethod.CARD,
  })
  method!: PaymentMethod;

  @Column({
    type: 'enum',
    enum: PaymentStatus,
    default: PaymentStatus.PENDING,
  })
  status!: PaymentStatus;

  @Column({ type: 'varchar', length: 80, nullable: true })
  provider?: string | null;

  @Column({
    name: 'external_reference',
    type: 'varchar',
    length: 120,
    nullable: true,
  })
  externalReference?: string | null;

  @Column({
    name: 'failure_reason',
    type: 'varchar',
    length: 255,
    nullable: true,
  })
  failureReason?: string | null;

  @Column({ name: 'paid_at', type: 'datetime', precision: 6, nullable: true })
  paidAt?: Date | null;
}
