import { ref } from 'vue';

const API_URL = import.meta.env.VITE_API_BASE_URL;

console.log(API_URL);
export interface LoginCredentials {
  username: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
}

export class LoginService {
  private static instance: LoginService;
  private isAuthenticated = ref(false);

  private constructor() {
    this.checkExistingToken();
  }

  static getInstance(): LoginService {
    if (!LoginService.instance) {
      LoginService.instance = new LoginService();
    }
    return LoginService.instance;
  }

  private checkExistingToken(): void {
    const token = localStorage.getItem('accessToken');
    this.isAuthenticated.value = !!token;
  }

  async login(credentials: LoginCredentials): Promise<boolean> {
    try {
      const response = await fetch(`${API_URL}/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(credentials),
      });

      if (!response.ok) {
        throw new Error('Login failed');
      }

      const data: LoginResponse = await response.json();

      // Store tokens securely
      localStorage.setItem('accessToken', data.accessToken);
      localStorage.setItem('refreshToken', data.refreshToken);

      this.isAuthenticated.value = true;
      return true;
    } catch (error) {
      this.isAuthenticated.value = false;
      throw new Error('Authentication failed');
    }
  }

  async logout(): Promise<void> {
    try {
      await fetch(`${API_URL}/api/logout`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${localStorage.getItem('accessToken')}`,
          'x-refresh-token': localStorage.getItem('refreshToken'),
        },
      });
    } finally {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      this.isAuthenticated.value = false;
    }
  }
  
  isLoggedIn(): boolean {
    return this.isAuthenticated.value;
  }

  getAccessToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  getRefreshToken(): string | null {
    return localStorage.getItem('refreshToken');
  }
}

export const loginService = LoginService.getInstance();
