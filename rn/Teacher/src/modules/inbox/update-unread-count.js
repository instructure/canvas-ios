//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

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
