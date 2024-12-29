<template>
  <div class="user-info-container">
    <h2>User Information</h2>

    <form @submit.prevent="handleSubmit" class="user-form">
      <div class="form-row">
        <div class="form-field">
          <label>ID</label>
          <input type="text" :value="user.id" disabled class="disabled" />
        </div>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>First Name</label>
          <input v-model="userForm.firstName" type="text" required />
        </div>

        <div class="form-field">
          <label>Last Name</label>
          <input v-model="userForm.lastName" type="text" required />
        </div>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>Address 1</label>
          <input v-model="userForm.address1" type="text" />
        </div>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>Address 2</label>
          <input v-model="userForm.address2" type="text" />
        </div>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>ZIP Code</label>
          <input v-model="userForm.zip" type="text" />
        </div>

        <div class="form-field">
          <label>Country</label>
          <input v-model="userForm.country" type="text" />
        </div>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>Subscription Plan</label>
          <input v-model="userForm.subscriptionPlan.name" type="text" />
        </div>

        <div class="form-field">
          <label>Status</label>
          <input v-model="userForm.subscriptionPlan.status" type="text" />
        </div>
      </div>

      <div class="form-row dns-container">
        <div class="form-field">
          <label>DNS Entries</label>
          <div class="dns-list">
            <div
              v-for="(dns, index) in userForm.dns"
              :key="index"
              class="dns-entry"
            >
              <input
                v-model="userForm.dns[index]"
                type="text"
                placeholder="Enter DNS"
              />
              <button
                type="button"
                class="remove-dns"
                @click="removeDns(index)"
              >
                ×
              </button>
            </div>
          </div>
          <button type="button" class="add-dns" @click="addDns">
            + Add DNS
          </button>
        </div>
      </div>
      <div class="button-group">
        <button type="submit" class="save-button">Save Changes</button>
        <button type="button" @click="resetForm" class="reset-button">
          Reset
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';
import { usersService } from '../../services/users.service';

const props = defineProps<{
  user: {
    id: string;
    firstName: string;
    lastName: string;
    address1: string;
    address2: string;
    zip: string;
    country: string;
    subscriptionPlan: {
      name: string;
      status: string;
    };
    dns: Array<string>;
  };
}>();

const userForm = ref({ ...props.user });

watch(
  () => props.user,
  (newUser) => {
    userForm.value = { ...newUser };
  },
  { deep: true }
);

const addDns = () => {
  userForm.value.dns.push('');
};

const removeDns = (index: number) => {
  userForm.value.dns.splice(index, 1);
};

const handleSubmit = async () => {
  try {
    await usersService.updateUser(props.user.id, userForm.value);
    // Handle successful update
  } catch (error) {
    console.error('Failed to update user:', error);
  }
};

const resetForm = () => {
  userForm.value = { ...props.user };
};
</script>

<style scoped>
.user-info-container {
  padding: 24px;
  max-width: 800px;
  margin: 0 auto;
}

.user-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-row {
  display: flex;
  gap: 20px;
}

.form-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

label {
  font-weight: 500;
  color: var(--text-color);
}

input {
  padding: 10px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.2s;
}

input:focus {
  border-color: #3b82f6;
  outline: none;
}

input.disabled {
  background-color: var(--disabled-bg);
  cursor: not-allowed;
}

.button-group {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 20px;
}

button {
  padding: 10px 20px;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.save-button {
  background: #3b82f6;
  color: white;
  border: none;
}

.save-button:hover {
  background: #2563eb;
}

.reset-button {
  background: transparent;
  border: 1px solid var(--border-color);
}

.reset-button:hover {
  background: var(--hover-bg);
}

:root {
  --text-color: #1e293b;
  --border-color: #e2e8f0;
  --disabled-bg: #f1f5f9;
  --hover-bg: #f8fafc;
}

@media (prefers-color-scheme: dark) {
  :root {
    --text-color: #e2e8f0;
    --border-color: #475569;
    --disabled-bg: #334155;
    --hover-bg: #334155;
  }
}

@media (max-width: 640px) {
  .form-row {
    flex-direction: column;
  }
}

.dns-container {
  margin-top: 1rem;
}

.dns-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.dns-entry {
  display: flex;
  gap: 8px;
  align-items: center;
}

.dns-entry input {
  flex: 1;
}

.remove-dns {
  padding: 6px 10px;
  border-radius: 4px;
  background: #ef4444;
  color: white;
  border: none;
  font-size: 16px;
  line-height: 1;
}

.add-dns {
  margin-top: 8px;
  padding: 8px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.add-dns:hover {
  background: #2563eb;
}

.remove-dns:hover {
  background: #dc2626;
}
</style>
