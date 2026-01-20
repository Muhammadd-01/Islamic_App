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

// Scientists API
export const scientistsApi = {
    getAll: () => api.get('/scientists'),
    create: (data) => api.post('/scientists', data),
    update: (id, data) => api.put(`/scientists/${id}`, data),
    delete: (id) => api.delete(`/scientists/${id}`),
};

// Inventions API
export const inventionsApi = {
    getAll: () => api.get('/inventions'),
    create: (data) => api.post('/inventions', data),
    update: (id, data) => api.put(`/inventions/${id}`, data),
    delete: (id) => api.delete(`/inventions/${id}`),
};

// History API
export const historyApi = {
    getAll: () => api.get('/history'),
    create: (data) => api.post('/history', data),
    update: (id, data) => api.put(`/history/${id}`, data),
    delete: (id) => api.delete(`/history/${id}`),
};

// Courses API
export const coursesApi = {
    getAll: () => api.get('/courses'),
    create: (data) => api.post('/courses', data),
    update: (id, data) => api.put(`/courses/${id}`, data),
    delete: (id) => api.delete(`/courses/${id}`),
};

// Duas API
export const duasApi = {
    getAll: () => api.get('/duas'),
    create: (data) => api.post('/duas', data),
    update: (id, data) => api.put(`/duas/${id}`, data),
    delete: (id) => api.delete(`/duas/${id}`),
};

// News API
export const newsApi = {
    getAll: () => api.get('/news'),
    create: (data) => api.post('/news', data),
    update: (id, data) => api.put(`/news/${id}`, data),
    delete: (id) => api.delete(`/news/${id}`),
};

// Scholars API
export const scholarsApi = {
    getAll: () => api.get('/scholars'),
    create: (data) => api.post('/scholars', data),
    update: (id, data) => api.put(`/scholars/${id}`, data),
    delete: (id) => api.delete(`/scholars/${id}`),
};

// Politics API
export const politicsApi = {
    getAll: () => api.get('/politics'),
    create: (data) => api.post('/politics', data),
    update: (id, data) => api.put(`/politics/${id}`, data),
    delete: (id) => api.delete(`/politics/${id}`),
};

// Hadiths API
export const hadithsApi = {
    getAll: () => api.get('/hadiths'),
    create: (data) => api.post('/hadiths', data),
    update: (id, data) => api.put(`/hadiths/${id}`, data),
    delete: (id) => api.delete(`/hadiths/${id}`),
};

// Quran API
export const quranApi = {
    getAll: () => api.get('/quran'),
    create: (data) => api.post('/quran', data),
    update: (id, data) => api.put(`/quran/${id}`, data),
    delete: (id) => api.delete(`/quran/${id}`),
};

// Religions (Beliefs) API
export const religionsApi = {
    getAll: () => api.get('/religions'),
    create: (data) => api.post('/religions', data),
    update: (id, data) => api.put(`/religions/${id}`, data),
    delete: (id) => api.delete(`/religions/${id}`),
};

// Daily Inspiration API
export const inspirationApi = {
    getAll: () => api.get('/inspiration'),
    create: (data) => api.post('/inspiration', data),
    delete: (id) => api.delete(`/inspiration/${id}`),
};

export default api;
