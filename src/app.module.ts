import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';

import { DataSource } from 'typeorm';

export const databaseProviders = [
  {
    provide: 'DATA_SOURCE',
    useFactory: async () => {
      const dataSource = new DataSource({
        type: 'mysql',
        host: 'mysql',
        port: 3306,
        username: 'rocketseat',
        password: 'MinhaSenhaDoMySql2026',
        database: 'rocketseat-db',
        entities: [__dirname + '/../**/*.entity{.ts,.js}'],
        synchronize: true,
      });

      const prom = dataSource
        .initialize()
        .then(() => {
          console.info('Data Source has been initialized!');
          return dataSource;
        })
        .catch((err) => {
          console.error('Error during Data Source initialization', err);
        });

      return prom;
    },
  },
];

@Module({
  imports: [],
  controllers: [AppController],
  providers: [...databaseProviders, AppService],
})
export class AppModule {}
