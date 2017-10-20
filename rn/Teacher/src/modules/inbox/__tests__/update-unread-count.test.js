// @flow

import canvas from 'instructure-canvas-api'
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
