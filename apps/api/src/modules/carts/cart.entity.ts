import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { User } from '../users/user.entity';

export enum CartStatus {
  OPEN = 'open',
  CONVERTED = 'converted',
  ABANDONED = 'abandoned',
}

@Entity('carts')
export class Cart extends BaseEntity {
  @Column({ name: 'user_id', type: 'char', length: 36, nullable: true })
  userId?: string | null;

  @ManyToOne(() => User, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'user_id' })
  user?: User | null;

  @Column({ name: 'session_token', type: 'varchar', length: 100, nullable: true })
  sessionToken?: string | null;

  @Column({ type: 'char', length: 3, default: 'USD' })
  currency!: string;

  @Column({
    type: 'enum',
    enum: CartStatus,
    default: CartStatus.OPEN,
  })
  status!: CartStatus;

  @Column({
    name: 'expires_at',
    type: 'datetime',
    precision: 6,
    nullable: true,
  })
  expiresAt?: Date | null;
}
