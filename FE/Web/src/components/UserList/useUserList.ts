import { ref } from 'vue';
import { usersService } from '../../services/users.service';

export function useUserList() {
  const users = ref([]);
  const searchQuery = ref('');
  const isLoading = ref(false);
  const error = ref(null as null | string);

  const fetchUsers = async () => {
    isLoading.value = true;
    try {
      users.value = await usersService.getUsers();
      console.log(users.value);
    } catch (err) {
      console.log(err);
      error.value = 'Failed to fetch users';
    } finally {
      isLoading.value = false;
    }
  };

  const searchUsers = async (query: string) => {
    isLoading.value = true;
    try {
      users.value = await usersService.searchUsers(query);
    } catch (err) {
      console.log(err);
      error.value = 'Search failed';
    } finally {
      isLoading.value = false;
    }
  };

  return {
    users,
    searchQuery,
    isLoading,
    error,
    fetchUsers,
    searchUsers,
  };
}
