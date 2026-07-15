import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  app.enableCors({
    origin: [
      process.env.WEB_ORIGIN ?? 'http://localhost:3000',
      process.env.ADMIN_ORIGIN ?? 'http://localhost:3001',
    ],
    credentials: true,
  });

  app.setGlobalPrefix('api');

  const swaggerConfig = new DocumentBuilder()
    .setTitle('Sanaa.co API')
    .setDescription(
      'CRUD API for Sanaa.co — catalog, commerce, CRM, purchasing and logistics.',
    )
    .setVersion('0.1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'JWT access token (auth coming next)',
      },
      'access-token',
    )
    .addTag('root', 'API metadata')
    .addTag('health', 'Health check')
    .addTag('users', 'Users CRUD')
    .addTag('addresses', 'Addresses CRUD')
    .addTag('categories', 'Categories CRUD')
    .addTag('subcategories', 'Subcategories CRUD')
    .addTag('products', 'Products CRUD')
    .addTag('product-variants', 'Product variants CRUD')
    .addTag('carts', 'Carts CRUD')
    .addTag('cart-items', 'Cart items CRUD')
    .addTag('orders', 'Orders CRUD')
    .addTag('order-items', 'Order items CRUD')
    .addTag('payments', 'Payments CRUD')
    .addTag('shipments', 'Shipments CRUD')
    .addTag('quotes', 'Quotes CRUD')
    .addTag('suppliers', 'Suppliers CRUD')
    .addTag('raw-materials', 'Raw materials CRUD')
    .addTag('warehouses', 'Warehouses CRUD')
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, document, {
    useGlobalPrefix: true,
    jsonDocumentUrl: 'docs-json',
    swaggerOptions: {
      persistAuthorization: true,
      tagsSorter: 'alpha',
      operationsSorter: 'alpha',
    },
  });

  const port = Number(process.env.PORT ?? 4000);
  await app.listen(port);

  // eslint-disable-next-line no-console
  console.log(`Sanaa API listening on http://localhost:${port}/api`);
  // eslint-disable-next-line no-console
  console.log(`Swagger UI available at http://localhost:${port}/api/docs`);
}

void bootstrap();
