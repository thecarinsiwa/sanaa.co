import { Column, Entity } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';

@Entity('suppliers')
export class Supplier extends BaseEntity {
  @Column({ name: 'company_name', type: 'varchar', length: 255 })
  companyName!: string;

  @Column({ name: 'contact_name', type: 'varchar', length: 150, nullable: true })
  contactName?: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email?: string | null;

  @Column({ type: 'varchar', length: 40, nullable: true })
  phone?: string | null;

  @Column({ type: 'text', nullable: true })
  address?: string | null;

  @Column({ name: 'country_code', type: 'char', length: 2, nullable: true })
  countryCode?: string | null;

  @Column({
    name: 'payment_terms',
    type: 'varchar',
    length: 120,
    nullable: true,
  })
  paymentTerms?: string | null;

  @Column({ name: 'is_active', type: 'tinyint', width: 1, default: 1 })
  isActive!: boolean;
}
