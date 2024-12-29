<template>
  <div class="login-container">
    <div class="login-box">
      <h2>Welcome Back</h2>
      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label for="username">Username</label>
          <input
            id="username"
            v-model="username"
            type="text"
            :class="{ error: usernameError }"
            @input="(e) => validateUsername(username, setUsernameError)"
            placeholder="Enter username"
          />
          <span class="error-message" v-if="usernameError">{{
            usernameError
          }}</span>
        </div>

        <div class="form-group">
          <label for="password">Password</label>
          <input
            id="password"
            v-model="password"
            type="password"
            :class="{ error: passwordError }"
            @input="(e) => validatePassword(password, setUsernameError)"
            placeholder="Enter password"
          />
          <span class="error-message" v-if="passwordError">{{
            passwordError
          }}</span>
        </div>

        <button type="submit" :disabled="!isFormValid">Login</button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { loginService } from '../../services/login.service';
import { useRouter } from 'vue-router';
import { validateUsername, validatePassword } from './utils';

const router = useRouter();
const username = ref('');
const password = ref('');
const usernameError = ref('');
const passwordError = ref('');

const isFormValid = computed(() => {
  return (
    username.value &&
    password.value &&
    !usernameError.value &&
    !passwordError.value
  );
});

const setUsernameError = (error: string) => {
  usernameError.value = error;
};

const setPasswordError = (error: string) => {
  passwordError.value = error;
};

const handleLogin = async () => {
  if (!isFormValid.value) return;

  try {
    const success = await loginService.login({
      username: username.value,
      password: password.value,
    });

    if (success) {
      router.push('/dashboard');
    }
  } catch (error) {
    console.error('Login failed:', error);
  }
};
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: var(--bg);
  padding: 20px;
  transition: background 0.3s ease;
}

.login-box {
  background: var(--card-bg);
  padding: 3rem 2.5rem;
  border-radius: 20px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
  width: 100%;
  max-width: 420px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transform: translateY(0);
  transition: all 0.3s ease;
}

h2 {
  color: var(--text);
  text-align: center;
  margin-bottom: 2.5rem;
  font-size: 2rem;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  color: var(--text);
  font-weight: 500;
  margin-bottom: 8px;
  display: block;
  font-size: 0.95rem;
}

input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid var(--input-border);
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: var(--input-bg);
  color: var(--text);
}

input:focus {
  border-color: #2196f3;
  box-shadow: 0 0 0 4px rgba(33, 150, 243, 0.1);
  outline: none;
}

input.error {
  border-color: #ff5252;
  background-color: #fff8f8;
}

.error-message {
  color: #ff5252;
  font-size: 0.85rem;
  margin-top: 6px;
  display: block;
}

button {
  width: 100%;
  padding: 14px;
  background: var(--button-gradient);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 1rem;
  text-transform: uppercase;
  letter-spacing: 1px;
}

button:hover:not(:disabled) {
  background: linear-gradient(45deg, #1976d2, #1565c0);
  box-shadow: 0 6px 20px rgba(33, 150, 243, 0.3);
}

button:disabled {
  background: linear-gradient(45deg, #b0bec5, #90a4ae);
  cursor: not-allowed;
}

@media (max-width: 480px) {
  .login-box {
    padding: 2rem 1.5rem;
  }
}
</style>
