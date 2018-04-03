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
import { isTeacher } from '../app'

export let interval: ?any

const TabBarBadgeCounts = NativeModules.TabBarBadgeCounts

export async function updateBadgeCounts () {
  try {
    const unread = canvas.getUnreadConversationsCount().then(({ data: unread }) =>
      TabBarBadgeCounts.updateUnreadMessageCount(unread.unread_count || 0)
    )
    if (isTeacher()) {
      await canvas.getToDoCount().then(({ data: todo }) =>
        TabBarBadgeCounts.updateTodoListCount(todo.needs_grading_count)
      )
    }
    await unread
  } catch (e) {}
}

export async function beginUpdatingBadgeCounts () {
  stopUpdatingBadgeCounts()
  interval = setInterval(updateBadgeCounts, 2 * 60 * 1000) // every 2 minutes
  await updateBadgeCounts()
}

export function stopUpdatingBadgeCounts (): void {
  if (!interval) {
    return
  }
  clearInterval(interval)
  interval = undefined
}
