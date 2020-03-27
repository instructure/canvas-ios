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

// @flow

import i18n from 'format-message'
import { handleActions } from 'redux-actions'
import AccountNotificationActions from './account-notification-actions'
import handleAsync from '../../utils/handleAsync'
import { parseErrorMessage } from '../../redux/middleware/error-handler'

const defaultState: AccountNotificationState = {
  pending: 0,
  list: [],
  closing: [],
  error: '',
  liveConferencesPending: 0,
  liveConferences: [],
  liveConferencesError: '',
  liveConferencesIgnored: [],
}

export const accountNotifications = handleActions({
  [AccountNotificationActions.refreshNotifications.toString()]: handleAsync({
    pending: (state) => ({
      ...state,
      pending: state.pending + 1,
      error: '',
    }),
    resolved: (state, { result: { data } }) => ({
      ...state,
      pending: Math.max(0, state.pending - 1),
      list: data,
    }),
    rejected: (state, { error }) => {
      let message = i18n('There was a problem loading the announcements.')
      let reason = parseErrorMessage(error)
      if (reason) message += '\n\n' + reason
      return {
        ...state,
        pending: Math.max(0, state.pending - 1),
        error: message,
      }
    },
  }),
  [AccountNotificationActions.closeNotification.toString()]: handleAsync({
    pending: (state, { id }) => ({
      ...state,
      closing: state.closing.concat(id),
      error: '',
    }),
    resolved: (state, { id }) => ({
      ...state,
      list: state.list.filter(notification => notification.id !== id),
      closing: state.closing.filter(closeID => closeID !== id),
    }),
    rejected: (state, { id, error }) => {
      let message = i18n('There was a problem dismissing the announcement.')
      let reason = parseErrorMessage(error)
      if (reason) message += '\n\n' + reason
      return {
        ...state,
        closing: state.closing.filter(closeID => closeID !== id),
        error: message,
      }
    },
  }),
  [AccountNotificationActions.refreshLiveConferences.toString()]: handleAsync({
    pending: (state) => ({
      ...state,
      liveConferencesPending: state.pending + 1,
      liveConferencesError: '',
    }),
    resolved: (state, { result: { data } }) => ({
      ...state,
      liveConferencesPending: Math.max(0, state.pending - 1),
      liveConferences: data.conferences,
    }),
    rejected: (state, { error }) => {
      let message = i18n('There was a problem loading the live conferences.')
      let reason = parseErrorMessage(error)
      if (reason) message += '\n\n' + reason
      return {
        ...state,
        liveConferencesPending: Math.max(0, state.liveConferencesPending - 1),
        liveConferencesError: message,
      }
    },
  }),
  [AccountNotificationActions.ignoreLiveConference.toString()]: (state, { payload: { id } }) => ({
    ...state,
    liveConferencesIgnored: state.liveConferencesIgnored.includes(id)
      ? state.liveConferencesIgnored
      : state.liveConferencesIgnored.concat(id),
  }),
}, defaultState)
