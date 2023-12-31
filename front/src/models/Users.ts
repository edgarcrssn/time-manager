import { Team } from './Teams'

export enum Role {
  EMPLOYEE = 'employee',
  MANAGER = 'manager',
  GENERAL_MANAGER = 'general_manager',
}

export type User = {
  id: number
  username: string
  email: string
  role: Role
  team: Team
  hourly_rate: number
  additional_hourly_rate: number
  night_hourly_rate: number
}
