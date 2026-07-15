import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { User } from '../users/user.entity';

export enum QuoteStatus {
  DRAFT = 'draft',
  SENT = 'sent',
  ACCEPTED = 'accepted',
  REJECTED = 'rejected',
  EXPIRED = 'expired',
  CONVERTED = 'converted',
}

@Entity('quotes')
export class Quote extends BaseEntity {
  @Column({ name: 'quote_number', type: 'varchar', length: 40 })
  quoteNumber!: string;

  @Column({ name: 'user_id', type: 'char', length: 36, nullable: true })
  userId?: string | null;

  @ManyToOne(() => User, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'user_id' })
  user?: User | null;

  @Column({ name: 'sales_rep_id', type: 'char', length: 36, nullable: true })
  salesRepId?: string | null;

  @ManyToOne(() => User, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'sales_rep_id' })
  salesRep?: User | null;

  @Column({
    type: 'enum',
    enum: QuoteStatus,
    default: QuoteStatus.DRAFT,
  })
  status!: QuoteStatus;

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
    name: 'amount_incl_tax',
    type: 'decimal',
    precision: 14,
    scale: 2,
    default: 0,
  })
  amountInclTax!: string;

  @Column({ type: 'char', length: 3, default: 'USD' })
  currency!: string;

  @Column({ name: 'valid_until', type: 'date', nullable: true })
  validUntil?: string | null;

  @Column({ type: 'text', nullable: true })
  notes?: string | null;

  @Column({
    name: 'converted_order_id',
    type: 'char',
    length: 36,
    nullable: true,
  })
  convertedOrderId?: string | null;
}
