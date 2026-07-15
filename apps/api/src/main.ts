import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

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
      'API métier Sanaa.co — boutique, personnalisation, atelier (GPAO), stocks et finance.',
    )
    .setVersion('0.0.1')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'JWT access token (à brancher avec l’auth)',
      },
      'access-token',
    )
    .addTag('root', 'Métadonnées de l’API')
    .addTag('health', 'Disponibilité du service')
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
