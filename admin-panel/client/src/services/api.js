import axios from 'axios';

const API_BASE_URL = '/api';

const api = axios.create({
    baseURL: API_BASE_URL,
    // headers: { 'Content-Type': 'application/json' } // Removed to allow FormData
});

// Stats API
export const statsApi = {
    getDashboard: () => api.get('/stats'),
    getOrdersChart: (days = 7) => api.get(`/stats/orders-chart?days=${days}`),
};

// Users API
export const usersApi = {
    getAll: (params = {}) => api.get('/users', { params }),
    getById: (id) => api.get(`/users/${id}`),
    updateRole: (id, role) => api.patch(`/users/${id}/role`, { role }),
    delete: (id) => api.delete(`/users/${id}`),
    getStatsByRole: () => api.get('/users/stats/by-role'),
};

// Orders API
export const ordersApi = {
    getAll: (params = {}) => api.get('/orders', { params }),
    getById: (id) => api.get(`/orders/${id}`),
    updateStatus: (id, status) => api.patch(`/orders/${id}/status`, { status }),
    delete: (id) => api.delete(`/orders/${id}`),
    getStats: () => api.get('/orders/stats/summary'),
};

// Books API
export const booksApi = {
    getAll: () => api.get('/books'),
    getById: (id) => api.get(`/books/${id}`),
    create: (data) => api.post('/books', data),
    update: (id, data) => api.put(`/books/${id}`, data),
    delete: (id) => api.delete(`/books/${id}`),
};

// Questions API
export const questionsApi = {
    getAll: (params = {}) => api.get('/questions', { params }),
    getById: (id) => api.get(`/questions/${id}`),
    answer: (id, answer) => api.post(`/questions/${id}/answer`, { answer }),
    delete: (id) => api.delete(`/questions/${id}`),
    getStats: () => api.get('/questions/stats/summary'),
};

export default api;
