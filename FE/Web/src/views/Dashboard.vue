<template>
  <div class="dashboard">
    <div class="topbar">
      <h1>IPTV Admin Panel</h1>
      <button class="logout-btn" @click="handleLogout">Logout</button>
    </div>
    
    <div class="dashboard-content">
      <UserList @userSelected="handleUserSelection" />

      <main class="main-content">
        <div v-if="selectedUser" class="content-wrapper">
          <UserInfo :user="selectedUser" />
        </div>
        <div v-else class="empty-state">
          <h2>Select a user to view details</h2>
          <p>Choose a user from the list to view and edit their information</p>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { loginService } from '../services/login.service';
import UserList from '../components/UserList/UserList.vue';
import UserInfo from '../components/UserInfo/UserInfo.vue';

const router = useRouter();
const selectedUser = ref(null);

const handleUserSelection = (user) => {
  selectedUser.value = user;
};

const handleLogout = async () => {
  await loginService.logout();
  router.push('/');
};
</script>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: var(--dashboard-bg);
}

.topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background: var(--content-bg);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.topbar h1 {
  font-size: 1.5rem;
  color: var(--text-primary);
  margin: 0;
}

.logout-btn {
  padding: 0.5rem 1rem;
  background: #ef4444;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  transition: background 0.2s;
}

.logout-btn:hover {
  background: #dc2626;
}

.dashboard-content {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.main-content {
  flex: 1;
  overflow-y: auto;
  background: var(--content-bg);
}

.content-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
}

.empty-state {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: var(--text-secondary);
  padding: 24px;
  text-align: center;
}

.empty-state h2 {
  font-size: 24px;
  margin-bottom: 12px;
  color: var(--text-primary);
}

.empty-state p {
  font-size: 16px;
  max-width: 400px;
}

:root {
  --dashboard-bg: #f8fafc;
  --content-bg: #ffffff;
  --text-primary: #1e293b;
  --text-secondary: #64748b;
}

@media (prefers-color-scheme: dark) {
  :root {
    --dashboard-bg: #0f172a;
    --content-bg: #1e293b;
    --text-primary: #e2e8f0;
    --text-secondary: #94a3b8;
  }
}

@media (max-width: 768px) {
  .dashboard {
    flex-direction: column;
  }
}
</style>
