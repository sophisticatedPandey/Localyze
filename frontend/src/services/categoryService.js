import api from './api';

const categoryService = {
  getAll: () => api.get('/categories'),

  createCategory: (data) => api.post('/categories', data),

  updateCategory: (id, data) => api.put(`/categories/${id}`, data),

  deleteCategory: (id) => api.delete(`/categories/${id}`),
};

export default categoryService;
