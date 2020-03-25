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

import { accountNotifications as reducer } from '../account-notification-reducer'
import AccountNotificationActions from '../account-notification-actions'
import * as template from '../../../__templates__'

const { refreshNotifications, closeNotification, refreshLiveConferences, ignoreLiveConference } = AccountNotificationActions

describe('account notification reducer', () => {
  const defaultState = {
    pending: 0,
    list: [],
    closing: [],
    error: '',
    liveConferencesPending: 0,
    liveConferences: [],
    liveConferencesError: '',
    liveConferencesIgnored: [],
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

  describe('refreshLiveConferences', () => {
    const data = [
      template.liveConference({ id: '1' }),
      template.liveConference({ id: '2' }),
    ]
    const pending = {
      type: refreshLiveConferences.toString(),
      pending: true,
    }

    it('handles pending', () => {
      expect(reducer(undefined, pending)).toEqual({
        ...defaultState,
        liveConferencesPending: 1,
      })
    })

    it('handles resolved', () => {
      const beforeState = reducer(undefined, pending)
      const action = {
        type: refreshLiveConferences.toString(),
        payload: { result: { data } },
      }
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        liveConferencesPending: 0,
        liveConferences: data,
      })
    })

    it('handles errors', () => {
      const beforeState = reducer(undefined, pending)
      const action = {
        type: refreshLiveConferences.toString(),
        error: true,
        payload: { error: new Error('Doh!') },
      }
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        liveConferencesPending: 0,
        liveConferencesError: 'There was a problem loading the live conferences.\n\nDoh!',
      })
      action.payload.error = ''
      expect(reducer(beforeState, action)).toEqual({
        ...beforeState,
        liveConferencesPending: 0,
        liveConferencesError: 'There was a problem loading the live conferences.',
      })
    })
  })

  describe('ignoreLiveConference', () => {
    it('adds the id to the ignored list if not already there', () => {
      const beforeState = reducer(undefined, { type: '' })
      const action = ignoreLiveConference('1')
      const afterState = reducer(beforeState, action)
      expect(afterState).toEqual({
        ...beforeState,
        liveConferencesIgnored: [ '1' ],
      })
      expect(reducer(afterState, action)).toEqual(afterState)
    })
  })
})
