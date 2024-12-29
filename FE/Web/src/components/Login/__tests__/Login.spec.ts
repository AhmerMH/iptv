import { mount } from '@vue/test-utils';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import Login from '../Login.vue';
import { loginService } from '../../../services/login.service';
import { createRouter, createWebHistory } from 'vue-router';

// Mock router
const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/dashboard', name: 'dashboard', redirect: { name: 'home' } },
  ],
});

// Mock login service
vi.mock('../../../services/login.service', () => ({
  loginService: {
    login: vi.fn(),
  },
}));

describe('Login.vue', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders login form correctly', () => {
    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    });

    expect(wrapper.find('h2').text()).toBe('Welcome Back');
    expect(wrapper.find('#username').exists()).toBe(true);
    expect(wrapper.find('#password').exists()).toBe(true);
    expect(wrapper.find('button[type="submit"]').exists()).toBe(true);
  });

  it('validates form fields', async () => {
    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    });

    const submitButton = wrapper.find('button[type="submit"]');
    expect(submitButton.attributes('disabled')).toBeDefined();

    await wrapper.find('#username').setValue('admin');
    await wrapper.find('#password').setValue('admin1');

    expect(submitButton.attributes('disabled')).toBeUndefined();
  });

  it('handles successful login', async () => {
    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    });

    vi.mocked(loginService.login).mockResolvedValueOnce(true);

    await wrapper.find('#username').setValue('admin');
    await wrapper.find('#password').setValue('admin1');
    await wrapper.find('form').trigger('submit');

    expect(loginService.login).toHaveBeenCalledWith({
      username: 'admin',
      password: 'admin1',
    });
  });

  it('handles login failure', async () => {
    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    });

    vi.mocked(loginService.login).mockRejectedValueOnce(
      new Error('Login failed')
    );

    await wrapper.find('#username').setValue('wrong1');
    await wrapper.find('#password').setValue('wrong1');
    await wrapper.find('form').trigger('submit');

    expect(loginService.login).toHaveBeenCalledWith({
      username: 'wrong1',
      password: 'wrong1',
    });
  });

  it('validates username format', async () => {
    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    });

    const usernameInput = wrapper.find('#username');
    await usernameInput.setValue('a');

    expect(wrapper.find('.error-message').exists()).toBe(true);
  });

  it('validates password format', async () => {
    const wrapper = mount(Login, {
      global: {
        plugins: [router],
      },
    });

    const passwordInput = wrapper.find('#password');
    await passwordInput.setValue('short');

    expect(wrapper.find('.error-message').exists()).toBe(true);
  });
});
