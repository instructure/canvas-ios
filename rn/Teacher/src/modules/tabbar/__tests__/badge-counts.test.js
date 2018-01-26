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

// @flow

import canvas from '../../../canvas-api'
import { beginUpdatingBadgeCounts, stopUpdatingBadgeCounts, updateBadgeCounts, interval } from '../badge-counts'

jest.mock('../../../canvas-api', () => {
  return {
    getUnreadConversationsCount: jest.fn(() => Promise.resolve({ data: {} })),
    getToDoCount: jest.fn(() => Promise.resolve({ data: {} })),
  }
})

describe('update counts', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  test('begin starts a timer', () => {
    beginUpdatingBadgeCounts()
    expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
    expect(interval).toBeDefined()
  })

  test('fetches unread count', async () => {
    await updateBadgeCounts()
    expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
    expect(canvas.getToDoCount).not.toHaveBeenCalled()
  })

  test('stops timer', () => {
    beginUpdatingBadgeCounts()
    expect(interval).toBeDefined()
    stopUpdatingBadgeCounts()
    expect(interval).not.toBeDefined()
  })
})
