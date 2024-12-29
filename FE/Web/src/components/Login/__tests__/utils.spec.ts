
import { describe, it, expect, vi } from 'vitest'
import { validateUsername, validatePassword } from '../utils'

describe('validateUsername', () => {
  const mockSetError = vi.fn()

  it('should return true for valid username', () => {
    const result = validateUsername('validuser', mockSetError)
    expect(result).toBe(true)
    expect(mockSetError).toHaveBeenCalledWith('')
  })

  it('should return false for username with SQL injection patterns', () => {
    const sqlPatterns = [
      "user'name",
      'user;name',
      'user--name',
      'SELECT username',
      'DROP table',
      'WHERE name'
    ]

    sqlPatterns.forEach(pattern => {
      const result = validateUsername(pattern, mockSetError)
      expect(result).toBe(false)
      expect(mockSetError).toHaveBeenCalledWith('Invalid characters detected')
    })
  })

  it('should return false for username shorter than 3 characters', () => {
    const result = validateUsername('ab', mockSetError)
    expect(result).toBe(false)
    expect(mockSetError).toHaveBeenCalledWith('Username must be at least 3 characters')
  })
})

describe('validatePassword', () => {
  const mockSetError = vi.fn()

  it('should return true for valid password', () => {
    const result = validatePassword('validpassword', mockSetError)
    expect(result).toBe(true)
    expect(mockSetError).toHaveBeenCalledWith('')
  })

  it('should return false for password shorter than 6 characters', () => {
    const result = validatePassword('short', mockSetError)
    expect(result).toBe(false)
    expect(mockSetError).toHaveBeenCalledWith('Password must be at least 6 characters')
  })
})
