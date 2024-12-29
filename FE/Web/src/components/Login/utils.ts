export const validateUsername = (
  username: string,
  setError: (error: string) => void
) => {
  const sqlInjectionPattern =
    /['";=\-#]|--|\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|WHERE)\b/i;
  if (sqlInjectionPattern.test(username)) {
    setError('Invalid characters detected');
    return false;
  }
  if (username.length < 3) {
    setError('Username must be at least 3 characters');
    return false;
  }
  setError('');
  return true;
};

export const validatePassword = (
  password: string,
  setError: (error: string) => void
) => {
  if (password.length < 6) {
    setError('Password must be at least 6 characters');
    return false;
  }
  setError('');
  return true;
};
