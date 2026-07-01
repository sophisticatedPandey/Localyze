import api from './api';

const serviceService = {
  getAll: (params = {}) => api.get('/services', { params }),

  getNearbyServices: (params = {}) => api.get('/services/nearby', { params }),

  getServiceById: (id) => api.get(`/services/${id}`),

  createService: (data) => api.post('/services', data),

  updateService: (id, data) => api.put(`/services/${id}`, data),

  deleteService: (id) => api.delete(`/services/${id}`),

  getMyServices: (params = {}) => api.get('/services/my', { params }),

  getSellerServices: (sellerId, params = {}) => api.get(`/services/seller/${sellerId}`, { params }),
};

export default serviceService;
