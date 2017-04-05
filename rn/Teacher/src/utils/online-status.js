// @flow
import { NetInfo } from 'react-native'

let onlineStatus = 'wifi'
NetInfo.addEventListener('change', updateStatus)

export function updateStatus (status: string): void {
  onlineStatus = status
}

export function getOnlineStatus (): string {
  return onlineStatus
}

export function isOnline (): boolean {
  return onlineStatus !== 'none'
}
