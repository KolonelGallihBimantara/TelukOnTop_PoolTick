import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ApiKeyMiddleware } from './common/middleware/api-key.middleware';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { TicketsModule } from './tickets/tickets.module';
import { TransactionsModule } from './transactions/transactions.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    PrismaModule,
    TicketsModule,
    TransactionsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})

export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(ApiKeyMiddleware).forRoutes(
      'tickets',
      'transactions',
    );
  }
}