import api from './api';

const messageService = {
  getBookingMessages: (bookingId) => api.get(`/messages/booking/${bookingId}`),

  sendMessage: (data) => api.post('/messages', data),

  markAsRead: (messageId) => api.put(`/messages/${messageId}/read`),

  getUnreadCount: () => api.get('/messages/unread-count'),
};

export default messageService;
