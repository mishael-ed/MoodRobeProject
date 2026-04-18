import express, { Application, json, urlencoded } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { UserRoutes } from './modules/user/presentation/routes/UserRoutes';
import { AestheticRoutes } from './modules/aesthetic/presentation/routes/AestheticRoutes';
import { MerchantRoutes } from '@modules/merchant/presentation/routes/MerchantRoutes';
import { ProductRoutes } from './modules/product/presentation/routes/ProductRoutes';
import { CartRoutes } from '@modules/cart/presentation/routes/CartRoutes';
import { OrderRoutes } from '@modules/order/presentation/routes/OrderRoutes';
import { PaymentRoutes } from '@modules/payment/presentation/routes/PaymentRoutes';
import { AdminRoutes } from '@modules/admin/presentation/routes/AdminRoutes';
import { OutfitRoutes } from '@modules/outfit/presentation/routes/OutfitRoutes';

export const createApp = (): Application => {
    const app = express();

    // Security middleware
    app.use(helmet());

    // CORS configuration — JWT is sent via Authorization header, not cookies, so credentials:true is not needed
    app.use(cors({ origin: '*' }));

    // Body parsing
    app.use(json());
    app.use(urlencoded({ extended: true }));

    // Health check
    app.get('/health', (req, res) => {
        res.json({ status: 'ok', timestamp: new Date().toISOString() });
    });

    // Module routes
    app.use('/api/users', UserRoutes.create());
    app.use('/api/aesthetics', AestheticRoutes.create());
    app.use('/api/merchants', MerchantRoutes.create());
    app.use('/api/products', ProductRoutes.create());
    app.use('/api/cart', CartRoutes.create());
    app.use('/api/orders', OrderRoutes.create());
    app.use('/api/payments', PaymentRoutes.create());
    app.use('/api/admin', AdminRoutes.create());
    app.use('/api/outfits', OutfitRoutes.create());

    return app;
};