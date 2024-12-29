import { fileURLToPath, URL } from 'node:url';

import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import vueDevTools from 'vite-plugin-vue-devtools';

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const envConfig = {
    development: {
      VITE_API_BASE_URL: 'http://localhost:8000/api',
    },
    production: {
      VITE_API_BASE_URL: 'https://api.yourproductionurl.com/api',
    },
  }[mode ?? 'development'];

  return {
    define: {
      'import.meta.env.VITE_API_BASE_URL': JSON.stringify(
        envConfig!.VITE_API_BASE_URL
      ),
    },
    plugins: [vue(), vueDevTools()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
  };
});
