import { Role } from '../models/Users'

export const getRoleLabel = (role: Role): string => {
  switch (role) {
    case Role.GENERAL_MANAGER:
      return 'General manager'
    case Role.MANAGER:
      return 'Manager'
    default:
      return 'Employee'
  }
}
