import {
  MiddlewareConsumer,
  Module,
  NestModule,
  RequestMethod,
} from '@nestjs/common';

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

      // ADMIN TICKETS
      {
        path: 'tickets',
        method: RequestMethod.POST,
      },
      {
        path: 'tickets/:id',
        method: RequestMethod.PATCH,
      },
      {
        path: 'tickets/:id',
        method: RequestMethod.DELETE,
      },

      // ADMIN TRANSACTIONS
      {
        path: 'transactions',
        method: RequestMethod.GET,
      },

    );
  }
}