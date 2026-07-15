import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { User } from '../users/user.entity';

@Entity('addresses')
export class Address extends BaseEntity {
  @Column({ name: 'user_id', type: 'char', length: 36 })
  userId!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user?: User;

  @Column({ type: 'varchar', length: 80, nullable: true })
  label?: string | null;

  @Column({
    name: 'recipient_name',
    type: 'varchar',
    length: 200,
    nullable: true,
  })
  recipientName?: string | null;

  @Column({ type: 'varchar', length: 40, nullable: true })
  phone?: string | null;

  @Column({ type: 'varchar', length: 255 })
  line1!: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  line2?: string | null;

  @Column({ type: 'varchar', length: 120 })
  city!: string;

  @Column({
    name: 'state_province',
    type: 'varchar',
    length: 120,
    nullable: true,
  })
  stateProvince?: string | null;

  @Column({ name: 'postal_code', type: 'varchar', length: 30, nullable: true })
  postalCode?: string | null;

  @Column({ name: 'country_code', type: 'char', length: 2, default: 'CD' })
  countryCode!: string;

  @Column({
    name: 'is_default_shipping',
    type: 'tinyint',
    width: 1,
    default: 0,
  })
  isDefaultShipping!: boolean;

  @Column({
    name: 'is_default_billing',
    type: 'tinyint',
    width: 1,
    default: 0,
  })
  isDefaultBilling!: boolean;
}
