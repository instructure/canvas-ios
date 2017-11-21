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
import {
  interval,
  updateUnreadCount,
  beginUpdatingUnreadCount,
  stopUpdatingUnreadCount,
} from '../update-unread-count'

test('begin starts a timer', () => {
  beginUpdatingUnreadCount()
  expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
  expect(interval).toBeDefined()
})

test('fetches unread count', () => {
  updateUnreadCount()
  expect(canvas.getUnreadConversationsCount).toHaveBeenCalled()
})

test('stops timer', () => {
  beginUpdatingUnreadCount()
  expect(interval).toBeDefined()
  stopUpdatingUnreadCount()
  expect(interval).not.toBeDefined()
})
