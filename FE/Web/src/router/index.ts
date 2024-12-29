import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/Login.vue';
import { loginService } from '../services/login.service';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Login,
    },
    {
      path: '/about',
      name: 'about',
      component: () => import('../views/AboutView.vue'),
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('../views/Dashboard.vue'),
      meta: { requiresAuth: true },
    },
  ],
});

router.beforeEach((to, from, next) => {
  if (to.matched.some((record) => record.meta.requiresAuth)) {
    if (!loginService.isLoggedIn()) {
      next({ name: 'home' });
    } else {
      next();
    }
  } else {
    next();
  }
});

// Global error handler for token expiration
window.addEventListener('tokenExpired', () => {
  loginService.logout();
  router.push({ name: 'home' });
});

export default router;
