import { Column, Entity, JoinColumn, ManyToOne } from 'typeorm';
import { BaseEntity } from '../../common/entities/base.entity';
import { Product } from '../products/product.entity';
import { ProductVariant } from '../product-variants/product-variant.entity';
import { Cart } from '../carts/cart.entity';

@Entity('cart_items')
export class CartItem extends BaseEntity {
  @Column({ name: 'cart_id', type: 'char', length: 36 })
  cartId!: string;

  @ManyToOne(() => Cart, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'cart_id' })
  cart?: Cart;

  @Column({ name: 'product_id', type: 'char', length: 36 })
  productId!: string;

  @ManyToOne(() => Product, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'product_id' })
  product?: Product;

  @Column({ name: 'variant_id', type: 'char', length: 36, nullable: true })
  variantId?: string | null;

  @ManyToOne(() => ProductVariant, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'variant_id' })
  variant?: ProductVariant | null;

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
}
