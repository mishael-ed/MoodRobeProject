import { Response } from 'express';
import { validationResult } from 'express-validator';
import { AuthRequest } from '../middleware/AuthMiddleware';
import { AddFavoriteUseCase } from '../../application/use-cases/AddFavoriteUseCase';
import { RemoveFavoriteUseCase } from '../../application/use-cases/RemoveFavoriteUseCase';
import { GetUserFavoritesUseCase } from '../../application/use-cases/GetUserFavoritesUseCase';
import { CheckFavoriteUseCase } from '../../application/use-cases/CheckFavoriteUseCase';

export class UserFavoriteController {
    constructor(
        private readonly addFavoriteUseCase: AddFavoriteUseCase,
        private readonly removeFavoriteUseCase: RemoveFavoriteUseCase,
        private readonly getUserFavoritesUseCase: GetUserFavoritesUseCase,
        private readonly checkFavoriteUseCase: CheckFavoriteUseCase
    ) { }

    public addFavorite = async (req: AuthRequest, res: Response): Promise<void> => {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                res.status(400).json({ errors: errors.array() });
                return;
            }

            if (!req.userId) {
                res.status(401).json({ error: 'Unauthorized' });
                return;
            }

            const result = await this.addFavoriteUseCase.execute(req.userId, req.body);
            res.status(201).json(result);
        } catch (error) {
            this.handleError(error, res);
        }
    };

    public removeFavorite = async (req: AuthRequest, res: Response): Promise<void> => {
        try {
            if (!req.userId) {
                res.status(401).json({ error: 'Unauthorized' });
                return;
            }

            const productId = req.params.productId as string;
            await this.removeFavoriteUseCase.execute(req.userId, productId);
            res.status(200).json({ message: 'Favorite removed successfully' });
        } catch (error) {
            this.handleError(error, res);
        }
    };

    public getUserFavorites = async (req: AuthRequest, res: Response): Promise<void> => {
        try {
            if (!req.userId) {
                res.status(401).json({ error: 'Unauthorized' });
                return;
            }

            const result = await this.getUserFavoritesUseCase.execute(req.userId);
            res.status(200).json(result);
        } catch (error) {
            this.handleError(error, res);
        }
    };

    public checkFavorite = async (req: AuthRequest, res: Response): Promise<void> => {
        try {
            if (!req.userId) {
                res.status(401).json({ error: 'Unauthorized' });
                return;
            }

            const productId = req.params.productId as string;
            const isFavorite = await this.checkFavoriteUseCase.execute(req.userId, productId);
            res.status(200).json({ isFavorite });
        } catch (error) {
            this.handleError(error, res);
        }
    };

    private handleError(error: unknown, res: Response): void {
        if (error instanceof Error) {
            res.status(400).json({ error: error.message });
        } else {
            res.status(500).json({ error: 'Internal server error' });
        }
    }
}