import api from './api';

const bookingService = {
  createBooking: (data) => api.post('/bookings', data),

  getMyBookings: (params = {}) => api.get('/bookings/my', { params }),

  getSellerBookings: (params = {}) => api.get('/bookings/seller', { params }),

  getBookingById: (id) => api.get(`/bookings/${id}`),

  updateBookingStatus: (id, status) => api.put(`/bookings/${id}/status`, { status }),

  cancelBooking: (id, reason) => api.put(`/bookings/${id}/cancel`, { reason }),
};

export default bookingService;
