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

/* @flow */

import { accountNotifications as reducer } from '../account-notification-reducer'
import { default as AccountNotificationActions } from '../account-notification-actions'

const { refreshNotifications, closeNotification } = AccountNotificationActions

const template = {
  ...require('../../../__templates__/account-notification'),
}

describe('account notification reducer', () => {
  const defaultState = {
    pending: 0,
    list: [],
    closing: [],
    error: '',
  }

  it('has an empty defaultState', () => {
    expect(reducer(undefined, { type: '' })).toEqual(defaultState)
  })

  describe('refreshNotifications', () => {
    const data = [
      template.accountNotification({ id: '1' }),
      template.accountNotification({ id: '2' }),
    ]
    const pending = {
      type: refreshNotifications.toString(),
      pending: true,
    }

    it('handles pending', () => {
      expect(reducer(undefined, pending)).toEqual({
        ...defaultState,
        pending: 1,
      })
    })

    it('handles resolved', () => {
      const beforeState = reducer(undefined, pending)
      const action = {
        type: refreshNotifications.toString(),
        payload: { result: { data } },
      }
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        pending: 0,
        list: data,
      })
    })

    it('handles errors', () => {
      const beforeState = reducer(undefined, pending)
      const action = {
        type: refreshNotifications.toString(),
        error: true,
        payload: { error: new Error('Doh!') },
      }
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        pending: 0,
        error: 'There was a problem loading the announcements.\n\nDoh!',
      })
      action.payload.error = ''
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        pending: 0,
        error: 'There was a problem loading the announcements.',
      })
    })
  })

  describe('closeNotification', () => {
    const data = [
      template.accountNotification({ id: '1' }),
      template.accountNotification({ id: '2' }),
    ]
    const pending = {
      type: closeNotification.toString(),
      pending: true,
      payload: { id: '2' },
    }

    it('handles pending', () => {
      const beforeState = { ...defaultState, list: data }
      expect(reducer(beforeState, pending)).toEqual({
        ...beforeState,
        closing: [ '2' ],
      })
    })

    it('handles resolved', () => {
      const beforeState = reducer({ ...defaultState, list: data }, pending)
      const action = {
        type: closeNotification.toString(),
        payload: { id: '2', result: { data: null } },
      }
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        closing: [],
        list: data.slice(0, 1),
      })
    })

    it('handles errors', () => {
      const beforeState = reducer({ ...defaultState, list: data }, pending)
      const action = {
        type: closeNotification.toString(),
        error: true,
        payload: { id: '2', error: new Error('Doh!') },
      }
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        closing: [],
        error: 'There was a problem dismissing the announcement.\n\nDoh!',
      })
      action.payload.error = ''
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        closing: [],
        error: 'There was a problem dismissing the announcement.',
      })
    })
  })
})
