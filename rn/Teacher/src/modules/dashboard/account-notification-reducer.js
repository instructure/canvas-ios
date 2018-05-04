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
}, defaultState)
