import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Order } from '../orders/order.entity';

export enum ShipmentStatus {
  PREPARED = 'prepared',
  IN_TRANSIT = 'in_transit',
  DELIVERED = 'delivered',
  FAILED = 'failed',
  RETURNED = 'returned',
}

@Entity('shipments')
export class Shipment extends BaseEntity {
  @Column({ name: 'order_id', type: 'char', length: 36 })
  orderId!: string;

  @ManyToOne(() => Order, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'order_id' })
  order?: Order;

  @Column({ type: 'varchar', length: 120, nullable: true })
  carrier?: string | null;

  @Column({
    name: 'tracking_number',
    type: 'varchar',
    length: 120,
    nullable: true,
  })
  trackingNumber?: string | null;

  @Column({
    type: 'enum',
    enum: ShipmentStatus,
    default: ShipmentStatus.PREPARED,
  })
  status!: ShipmentStatus;

  @Column({
    name: 'shipped_at',
    type: 'datetime',
    precision: 6,
    nullable: true,
  })
  shippedAt?: Date | null;

  @Column({
    name: 'delivered_at',
    type: 'datetime',
    precision: 6,
    nullable: true,
  })
  deliveredAt?: Date | null;

  @Column({ name: 'shipping_address_snapshot', type: 'json', nullable: true })
  shippingAddressSnapshot?: Record<string, unknown> | null;
}
