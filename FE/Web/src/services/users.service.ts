const API_URL = import.meta.env.VITE_API_BASE_URL;

export class UsersService {
  private static instance: UsersService;

  static getInstance(): UsersService {
    if (!UsersService.instance) {
      UsersService.instance = new UsersService();
    }
    return UsersService.instance;
  }

  async getUsers() {
    const response = await fetch(`${API_URL}/users`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('accessToken')}`,
        'x-refresh-token': localStorage.getItem('refreshToken') || '',
      },
    });
    return response.json();
  }

  async searchUsers(query: string) {
    const response = await fetch(`${API_URL}/users/search?q=${query}`, {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('accessToken')}`,
        'x-refresh-token': localStorage.getItem('refreshToken') || '',
      },
    });
    return response.json();
  }

  async updateUser(userId: string, userData: any) {
    const response = await fetch(`${API_URL}/users/${userId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${localStorage.getItem('accessToken')}`,
        'x-refresh-token': localStorage.getItem('refreshToken') || '',
      },
      body: JSON.stringify(userData),
    });

    if (response.status === 403 || response.status === 401) {
      const newAccessToken = response.headers.get('x-access-token');
      const newRefreshToken = response.headers.get('x-refresh-token');

      if (newAccessToken && newRefreshToken) {
        localStorage.setItem('accessToken', newAccessToken);
        localStorage.setItem('refreshToken', newRefreshToken);
        return this.updateUser(userId, userData);
      }
    }

    return response.json();
  }
}

export const usersService = UsersService.getInstance();
