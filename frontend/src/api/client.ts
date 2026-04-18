import axios from 'axios';
import { setupInterceptors } from './interceptors'; 

const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://moodrobeproject-1.onrender.com/api';

export const apiClient = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
    timeout: 30000,
});

// Attach interceptors
setupInterceptors(apiClient);

export default apiClient;