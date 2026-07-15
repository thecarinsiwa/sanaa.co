/**
 * Generates NestJS CRUD modules for Sanaa API resources.
 * Run: node scripts/generate-crud.mjs
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');

const resources = [
  {
    folder: 'users',
    entity: 'User',
    entityFile: 'user.entity',
    route: 'users',
    tag: 'users',
    search: ['email', 'lastName', 'firstName'],
    createFields: `
  @ApiProperty({ example: 'client@sanaa.co' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: 'hashed-or-plain-for-now' })
  @IsString()
  @MinLength(6)
  passwordHash!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  lastName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  firstName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ enum: UserRole })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
`,
    imports: `import { UserRole } from './user.entity';
import { IsBoolean, IsEmail, IsEnum, IsOptional, IsString, MinLength } from 'class-validator';`,
  },
  {
    folder: 'categories',
    entity: 'Category',
    entityFile: 'category.entity',
    route: 'categories',
    tag: 'categories',
    search: ['name', 'slug'],
    createFields: `
  @ApiProperty({ example: 'Health' })
  @IsString()
  name!: string;

  @ApiProperty({ example: 'health' })
  @IsString()
  slug!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
`,
    imports: `import { IsBoolean, IsInt, IsOptional, IsString } from 'class-validator';`,
  },
  {
    folder: 'subcategories',
    entity: 'Subcategory',
    entityFile: 'subcategory.entity',
    route: 'subcategories',
    tag: 'subcategories',
    search: ['name', 'slug'],
    createFields: `
  @ApiProperty()
  @IsUUID()
  categoryId!: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty()
  @IsString()
  slug!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
`,
    imports: `import { IsBoolean, IsInt, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'products',
    entity: 'Product',
    entityFile: 'product.entity',
    route: 'products',
    tag: 'products',
    search: ['name', 'slug', 'sku'],
    createFields: `
  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  subcategoryId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sku?: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty()
  @IsString()
  slug!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  shortDescription?: string;

  @ApiPropertyOptional({ enum: ProductType })
  @IsOptional()
  @IsEnum(ProductType)
  productType?: ProductType;

  @ApiPropertyOptional({ example: '49.99' })
  @IsOptional()
  @IsString()
  basePrice?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  compareAtPrice?: string;

  @ApiPropertyOptional({ example: 'USD' })
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isFeatured?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
`,
    imports: `import { ProductType } from './product.entity';
import { IsBoolean, IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'product-variants',
    entity: 'ProductVariant',
    entityFile: 'product-variant.entity',
    route: 'product-variants',
    tag: 'product-variants',
    search: ['name', 'sku', 'color', 'size'],
    createFields: `
  @ApiProperty()
  @IsUUID()
  productId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sku?: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  size?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  color?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  barcode?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  price?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
`,
    imports: `import { IsBoolean, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'carts',
    entity: 'Cart',
    entityFile: 'cart.entity',
    route: 'carts',
    tag: 'carts',
    search: ['sessionToken'],
    createFields: `
  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sessionToken?: string;

  @ApiPropertyOptional({ example: 'USD' })
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional({ enum: CartStatus })
  @IsOptional()
  @IsEnum(CartStatus)
  status?: CartStatus;
`,
    imports: `import { CartStatus } from './cart.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'cart-items',
    entity: 'CartItem',
    entityFile: 'cart-item.entity',
    route: 'cart-items',
    tag: 'cart-items',
    search: [],
    createFields: `
  @ApiProperty()
  @IsUUID()
  cartId!: string;

  @ApiProperty()
  @IsUUID()
  productId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  variantId?: string;

  @ApiProperty({ example: '1' })
  @IsString()
  quantity!: string;

  @ApiProperty({ example: '49.99' })
  @IsString()
  unitPrice!: string;
`,
    imports: `import { IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'orders',
    entity: 'Order',
    entityFile: 'order.entity',
    route: 'orders',
    tag: 'orders',
    search: ['orderNumber'],
    createFields: `
  @ApiProperty({ example: 'ORD-1001' })
  @IsString()
  orderNumber!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  cartId?: string;

  @ApiPropertyOptional({ enum: OrderStatus })
  @IsOptional()
  @IsEnum(OrderStatus)
  status?: OrderStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  amountExclTax?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  taxAmount?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  shippingAmount?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  discountAmount?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  amountInclTax?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;
`,
    imports: `import { OrderStatus } from './order.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'order-items',
    entity: 'OrderItem',
    entityFile: 'order-item.entity',
    route: 'order-items',
    tag: 'order-items',
    search: ['label'],
    createFields: `
  @ApiProperty()
  @IsUUID()
  orderId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  productId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  variantId?: string;

  @ApiProperty()
  @IsString()
  label!: string;

  @ApiProperty({ example: '1' })
  @IsString()
  quantity!: string;

  @ApiProperty({ example: '49.99' })
  @IsString()
  unitPrice!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  taxRate?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  discountAmount?: string;

  @ApiProperty({ example: '49.99' })
  @IsString()
  lineTotal!: string;
`,
    imports: `import { IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'payments',
    entity: 'Payment',
    entityFile: 'payment.entity',
    route: 'payments',
    tag: 'payments',
    search: ['externalReference'],
    createFields: `
  @ApiProperty()
  @IsUUID()
  orderId!: string;

  @ApiProperty({ example: '49.99' })
  @IsString()
  amount!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional({ enum: PaymentMethod })
  @IsOptional()
  @IsEnum(PaymentMethod)
  method?: PaymentMethod;

  @ApiPropertyOptional({ enum: PaymentStatus })
  @IsOptional()
  @IsEnum(PaymentStatus)
  status?: PaymentStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  provider?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  externalReference?: string;
`,
    imports: `import { PaymentMethod, PaymentStatus } from './payment.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'shipments',
    entity: 'Shipment',
    entityFile: 'shipment.entity',
    route: 'shipments',
    tag: 'shipments',
    search: ['trackingNumber', 'carrier'],
    createFields: `
  @ApiProperty()
  @IsUUID()
  orderId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  carrier?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  trackingNumber?: string;

  @ApiPropertyOptional({ enum: ShipmentStatus })
  @IsOptional()
  @IsEnum(ShipmentStatus)
  status?: ShipmentStatus;
`,
    imports: `import { ShipmentStatus } from './shipment.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'suppliers',
    entity: 'Supplier',
    entityFile: 'supplier.entity',
    route: 'suppliers',
    tag: 'suppliers',
    search: ['companyName', 'email'],
    createFields: `
  @ApiProperty()
  @IsString()
  companyName!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  contactName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  countryCode?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  paymentTerms?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
`,
    imports: `import { IsBoolean, IsEmail, IsOptional, IsString } from 'class-validator';`,
  },
  {
    folder: 'raw-materials',
    entity: 'RawMaterial',
    entityFile: 'raw-material.entity',
    route: 'raw-materials',
    tag: 'raw-materials',
    search: ['code', 'name'],
    createFields: `
  @ApiProperty()
  @IsString()
  code!: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiPropertyOptional({ example: 'm' })
  @IsOptional()
  @IsString()
  unit?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  reorderLevel?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  defaultSupplierId?: string;
`,
    imports: `import { IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'warehouses',
    entity: 'Warehouse',
    entityFile: 'warehouse.entity',
    route: 'warehouses',
    tag: 'warehouses',
    search: ['code', 'name'],
    createFields: `
  @ApiProperty()
  @IsString()
  code!: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
`,
    imports: `import { IsBoolean, IsOptional, IsString } from 'class-validator';`,
  },
  {
    folder: 'quotes',
    entity: 'Quote',
    entityFile: 'quote.entity',
    route: 'quotes',
    tag: 'quotes',
    search: ['quoteNumber'],
    createFields: `
  @ApiProperty({ example: 'QT-1001' })
  @IsString()
  quoteNumber!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsUUID()
  salesRepId?: string;

  @ApiPropertyOptional({ enum: QuoteStatus })
  @IsOptional()
  @IsEnum(QuoteStatus)
  status?: QuoteStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  amountExclTax?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  taxAmount?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  amountInclTax?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;
`,
    imports: `import { QuoteStatus } from './quote.entity';
import { IsEnum, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
  {
    folder: 'addresses',
    entity: 'Address',
    entityFile: 'address.entity',
    route: 'addresses',
    tag: 'addresses',
    search: ['city', 'recipientName'],
    createFields: `
  @ApiProperty()
  @IsUUID()
  userId!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  label?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  recipientName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty()
  @IsString()
  line1!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  line2?: string;

  @ApiProperty()
  @IsString()
  city!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  stateProvince?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  postalCode?: string;

  @ApiPropertyOptional({ example: 'CD' })
  @IsOptional()
  @IsString()
  countryCode?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isDefaultShipping?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isDefaultBilling?: boolean;
`,
    imports: `import { IsBoolean, IsOptional, IsString, IsUUID } from 'class-validator';`,
  },
];

for (const r of resources) {
  const dir = path.join(root, 'src', 'modules', r.folder);
  fs.mkdirSync(dir, { recursive: true });

  const searchArray = JSON.stringify(r.search);

  const dto = `import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
${r.imports}

export class Create${r.entity}Dto {${r.createFields}}

export class Update${r.entity}Dto extends PartialType(Create${r.entity}Dto) {}
`;

  const service = `import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CrudService } from '../../common/crud/crud.service';
import { ${r.entity} } from './${r.entityFile}';

@Injectable()
export class ${r.entity}sService extends CrudService<${r.entity}> {
  constructor(
    @InjectRepository(${r.entity})
    repository: Repository<${r.entity}>,
  ) {
    super(repository);
  }

  protected override get searchFields() {
    return ${searchArray} as (keyof ${r.entity} & string)[];
  }
}
`;

  // Fix service class name - UsersService not UsersService from User -> UsersService; for ProductVariant -> ProductVariantsService
  // Actually I'm using `${r.entity}sService` which gives UsersService, CategorysService (wrong!)
  // Better naming: folder-based
  
  const serviceClass = toServiceClass(r.folder);
  const controllerClass = toControllerClass(r.folder);
  const moduleClass = toModuleClass(r.folder);

  const serviceFixed = service
    .replace(`export class ${r.entity}sService`, `export class ${serviceClass}`);

  const controller = `import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { PaginationQueryDto } from '../../common/dto/pagination.dto';
import { Create${r.entity}Dto, Update${r.entity}Dto } from './${kebab(r.entity)}.dto';
import { ${r.entity} } from './${r.entityFile}';
import { ${serviceClass} } from './${r.folder}.service';

@ApiTags('${r.tag}')
@Controller('${r.route}')
export class ${controllerClass} {
  constructor(private readonly service: ${serviceClass}) {}

  @Get()
  @ApiOperation({ summary: 'List ${r.route}' })
  @ApiOkResponse({ description: 'Paginated list' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.service.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get ${r.entity} by id' })
  @ApiOkResponse({ type: ${r.entity} })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create ${r.entity}' })
  @ApiCreatedResponse({ type: ${r.entity} })
  create(@Body() dto: Create${r.entity}Dto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update ${r.entity}' })
  @ApiOkResponse({ type: ${r.entity} })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: Update${r.entity}Dto,
  ) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft-delete ${r.entity}' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.service.remove(id);
  }
}
`;

  const moduleCode = `import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ${controllerClass} } from './${r.folder}.controller';
import { ${r.entity} } from './${r.entityFile}';
import { ${serviceClass} } from './${r.folder}.service';

@Module({
  imports: [TypeOrmModule.forFeature([${r.entity}])],
  controllers: [${controllerClass}],
  providers: [${serviceClass}],
  exports: [${serviceClass}],
})
export class ${moduleClass} {}
`;

  fs.writeFileSync(path.join(dir, `${kebab(r.entity)}.dto.ts`), dto);
  fs.writeFileSync(
    path.join(dir, `${r.folder}.service.ts`),
    serviceFixed,
  );
  fs.writeFileSync(path.join(dir, `${r.folder}.controller.ts`), controller);
  fs.writeFileSync(path.join(dir, `${r.folder}.module.ts`), moduleCode);
  console.log('generated', r.folder);
}

function kebab(name) {
  return name
    .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
    .replace(/_/g, '-')
    .toLowerCase();
}

function toServiceClass(folder) {
  return (
    folder
      .split('-')
      .map((p) => p.charAt(0).toUpperCase() + p.slice(1))
      .join('') + 'Service'
  );
}

function toControllerClass(folder) {
  return (
    folder
      .split('-')
      .map((p) => p.charAt(0).toUpperCase() + p.slice(1))
      .join('') + 'Controller'
  );
}

function toModuleClass(folder) {
  return (
    folder
      .split('-')
      .map((p) => p.charAt(0).toUpperCase() + p.slice(1))
      .join('') + 'Module'
  );
}
