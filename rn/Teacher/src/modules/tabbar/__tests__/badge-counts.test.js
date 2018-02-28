//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import { NativeModules } from 'react-native'
import canvas from '../../../canvas-api'
import { beginUpdatingBadgeCounts, stopUpdatingBadgeCounts, updateBadgeCounts, interval } from '../badge-counts'
import App from '../../app/index'

jest.mock('../../../canvas-api', () => {
  return {
    getUnreadConversationsCount: jest.fn(() => Promise.resolve({ data: {} })),
    getToDoCount: jest.fn(() => Promise.resolve({ data: {} })),
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

  it('fetches unread count and todo count for teachers', async () => {
    await updateBadgeCounts()
    expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
    expect(canvas.getToDoCount).toHaveBeenCalled()
    expect(NativeModules.TabBarBadgeCounts.updateUnreadMessageCount).toHaveBeenCalled()
    expect(NativeModules.TabBarBadgeCounts.updateTodoListCount).toHaveBeenCalled()
  })

  it('fetches unread count for student', async () => {
    App.setCurrentApp('student')
    await updateBadgeCounts()
    expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
    expect(canvas.getToDoCount).not.toHaveBeenCalled()
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
