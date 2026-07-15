import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RawMaterialsController } from './raw-materials.controller';
import { RawMaterial } from './raw-material.entity';
import { RawMaterialsService } from './raw-materials.service';

@Module({
  imports: [TypeOrmModule.forFeature([RawMaterial])],
  controllers: [RawMaterialsController],
  providers: [RawMaterialsService],
  exports: [RawMaterialsService],
})
export class RawMaterialsModule {}
