<template>
  <aside class="user-list-sidebar">
    <div class="search-container">
      <input
        type="search"
        v-model="searchQuery"
        @input="handleSearch"
        placeholder="Search users..."
        class="search-input"
      />
    </div>

    <div class="users-container">
      <div v-if="isLoading" class="loading">Loading users...</div>

      <div v-else-if="error" class="error">
        {{ error }}
      </div>

      <div v-else-if="users.length === 0" class="no-results">
        No users found
      </div>

      <ul v-else class="users-list">
        <li
          v-for="user in users"
          :key="user.id"
          @click="selectUser(user)"
          :class="{ active: selectedUserId === user.id }"
          class="user-item"
        >
          <div class="user-avatar">
            {{ user.firstName[0] + user.lastName[0] }}
          </div>
          <div class="user-info">
            <span class="user-name">{{ user.firstName }}</span>
            <span class="user-email">{{ user.email }}</span>
          </div>
        </li>
      </ul>
    </div>
  </aside>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useUserList } from './useUserList';

const emit = defineEmits(['userSelected']);
const selectedUserId = ref(null);
let searchTimeout: any = null;

const { users, searchQuery, isLoading, error, fetchUsers, searchUsers } =
  useUserList();

const handleSearch = async () => {
  if (searchTimeout) {
    clearTimeout(searchTimeout);
  }

  searchTimeout = setTimeout(async () => {
    if (searchQuery.value.length >= 2) {
      await searchUsers(searchQuery.value);
    } else {
      await fetchUsers();
    }
  }, 300);
};

const selectUser = (user) => {
  selectedUserId.value = user.id;
  emit('userSelected', user);
};

onMounted(fetchUsers);
</script>
<style scoped>
.user-list-sidebar {
  width: 300px;
  height: 100vh;
  border-right: 1px solid var(--border-color);
  background: var(--sidebar-bg);
  display: flex;
  flex-direction: column;
}

.search-container {
  padding: 16px;
  border-bottom: 1px solid var(--border-color);
}

.search-input {
  width: 100%;
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid var(--border-color);
  font-size: 14px;
}

.users-container {
  flex: 1;
  overflow-y: auto;
}

.users-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.user-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.user-item:hover {
  background-color: var(--hover-bg);
}

.user-item.active {
  background-color: var(--active-bg);
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--avatar-bg);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  font-weight: 500;
}

.active .user-avatar {
  border: 2px solid #1976d2;
}

.user-info {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-weight: 500;
  margin-bottom: 4px;
}

.user-email {
  font-size: 12px;
  color: var(--secondary-text);
}

.loading,
.error,
.no-results {
  padding: 20px;
  text-align: center;
  color: var(--secondary-text);
}
</style>
