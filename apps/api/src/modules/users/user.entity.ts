import { Column, Entity, Index } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';

export enum UserRole {
  CUSTOMER = 'customer',
  SALES = 'sales',
  WORKSHOP = 'workshop',
  PURCHASING = 'purchasing',
  FINANCE = 'finance',
  ADMIN = 'admin',
}

@Entity('users')
export class User extends BaseEntity {
  @Index()
  @Column({ type: 'varchar', length: 255 })
  email!: string;

  @Column({ name: 'password_hash', type: 'varchar', length: 255 })
  passwordHash!: string;

  @Column({ name: 'last_name', type: 'varchar', length: 120, nullable: true })
  lastName?: string | null;

  @Column({ name: 'first_name', type: 'varchar', length: 120, nullable: true })
  firstName?: string | null;

  @Column({ type: 'varchar', length: 40, nullable: true })
  phone?: string | null;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.CUSTOMER,
  })
  role!: UserRole;

  @Column({ name: 'is_active', type: 'tinyint', width: 1, default: 1 })
  isActive!: boolean;

  @Column({
    name: 'email_verified_at',
    type: 'datetime',
    precision: 6,
    nullable: true,
  })
  emailVerifiedAt?: Date | null;

  @Column({
    name: 'last_login_at',
    type: 'datetime',
    precision: 6,
    nullable: true,
  })
  lastLoginAt?: Date | null;
}
