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

// Tasbeeh API
export const tasbeehApi = {
    getAll: (params = {}) => api.get('/tasbeeh', { params }),
};

// Azkar API
export const azkarApi = {
    getAll: () => api.get('/azkar'),
    create: (data) => api.post('/azkar', data),
    update: (id, data) => api.put(`/azkar/${id}`, data),
    delete: (id) => api.delete(`/azkar/${id}`),
};

// Regions API
export const regionsApi = {
    getAll: () => api.get('/regions'),
    create: (data) => api.post('/regions', data),
    delete: (id) => api.delete(`/regions/${id}`),
};

// Reciters API
export const reciterApi = {
    getAll: () => api.get('/reciters'),
    create: (data) => api.post('/reciters', data),
    update: (id, data) => api.put(`/reciters/${id}`, data),
    delete: (id) => api.delete(`/reciters/${id}`),
};

// Adhans API
export const adhanApi = {
    getAll: () => api.get('/adhans'),
    create: (data) => api.post('/adhans', data),
    update: (id, data) => api.put(`/adhans/${id}`, data),
    delete: (id) => api.delete(`/adhans/${id}`),
};

// Donations API
export const donationsApi = {
    getAll: () => api.get('/donations'),
    updateStatus: (id, status) => api.patch(`/donations/${id}/status`, { status }),
    delete: (id) => api.delete(`/donations/${id}`),
    getSettings: () => api.get('/donations/settings'),
    updateSettings: (data) => api.post('/donations/settings', data),
};

// Bookings API
export const bookingsApi = {
    getAll: () => api.get('/bookings'),
    getByScholar: (scholarId) => api.get(`/bookings/scholar/${scholarId}`),
    create: (data) => api.post('/bookings', data),
};

// Enrollments API
export const enrollmentsApi = {
    getAll: () => api.get('/enrollments'),
    updateStatus: (id, status) => api.patch(`/enrollments/${id}/status`, { status }),
    delete: (id) => api.delete(`/enrollments/${id}`),
};

// Settings API
export const settingsApi = {
    getWhatsApp: () => api.get('/settings/whatsapp'),
    updateWhatsApp: (data) => api.post('/settings/whatsapp', data),
    resetWhatsApp: () => api.post('/settings/whatsapp/reset'),

    getAdminData: () => api.get('/settings/admin/profile-data'),
    updateAdminData: (data) => api.post('/settings/admin/profile-data', data),
    updateAdminProfileImage: (formData) => api.post('/settings/admin/profile-image', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
    }),
    removeAdminProfileImage: () => api.delete('/settings/admin/profile-image'),
};

export default api;
