// @flow
import { NativeModules } from 'react-native'
import canvas from '../../canvas-api'

export let interval: ?any

const UnreadMessages = NativeModules.UnreadMessages

export async function updateUnreadCount (): * {
  try {
    let { data } = await canvas.getUnreadConversationsCount()
    let { unread_count: count } = data
    UnreadMessages.updateUnreadCount(count)
    return count
  } catch (error) {
    console.log('There was a prolem getting the `unread_count`', error)
  }
}

export async function beginUpdatingUnreadCount (): * {
  stopUpdatingUnreadCount()
  interval = setInterval(updateUnreadCount, 2 * 60 * 1000) // every 2 minutes
  let count = await updateUnreadCount()
  return count
}

export function stopUpdatingUnreadCount (): void {
  if (!interval) {
    return
  }
  clearInterval(interval)
  interval = undefined
}
