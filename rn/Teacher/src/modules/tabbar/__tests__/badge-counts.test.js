//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import { NativeModules } from 'react-native'
import canvas from '../../../canvas-api'
import { beginUpdatingBadgeCounts, stopUpdatingBadgeCounts, updateBadgeCounts, interval } from '../badge-counts'

jest.mock('../../../canvas-api', () => {
  return {
    getUnreadConversationsCount: jest.fn(() => Promise.resolve({ data: {} })),
  }
})

describe('update counts', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('begin starts a timer', () => {
    beginUpdatingBadgeCounts()
    expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
    expect(interval).toBeDefined()
  })

  it('fetches unread count for student', async () => {
    await updateBadgeCounts()
    expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
    expect(NativeModules.TabBarBadgeCounts.updateUnreadMessageCount).toHaveBeenCalled()
  })

  it('fails when an error occurs', async () => {
    canvas.getUnreadConversationsCount.mockImplementationOnce(() => Promise.resolve({}))
    await updateBadgeCounts()
    expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
    expect(NativeModules.TabBarBadgeCounts.updateUnreadMessageCount).not.toHaveBeenCalled()
  })

  it('stops timer', () => {
    beginUpdatingBadgeCounts()
    expect(interval).toBeDefined()
    stopUpdatingBadgeCounts()
    expect(interval).not.toBeDefined()
  })
})
