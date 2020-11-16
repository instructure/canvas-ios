//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow
import { NativeModules } from 'react-native'
import canvas from '../../canvas-api'

export let interval: ?any

const TabBarBadgeCounts = NativeModules.TabBarBadgeCounts

export async function updateBadgeCounts () {
  try {
    const unread = canvas.getUnreadConversationsCount().then(({ data: unread }) =>
      TabBarBadgeCounts.updateUnreadMessageCount(+unread.unread_count || 0)
    )
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
