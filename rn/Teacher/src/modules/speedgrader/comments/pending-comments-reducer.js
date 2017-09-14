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

import { Reducer } from 'redux'
import Actions from './actions'
import { NativeModules } from 'react-native'
import { handleActions } from 'redux-actions'
import i18n from 'format-message'
import handleAsync from '../../../utils/handleAsync'
import SubmissionActions from '../../submissions/list/actions'
import { parseErrorMessage } from '../../../redux/middleware/error-handler'

const { PushNotifications } = NativeModules
const { makeAComment, deletePendingComment } = Actions
const { refreshSubmissions } = SubmissionActions

const pendingComments: Reducer<PendingCommentsState, any> = handleActions({
  [refreshSubmissions.toString()]: handleAsync({
    resolved: (state) => {
      return Object.keys(state).reduce((newState, key) => {
        const unMatched = state[key].filter(comment => {
          return !comment.commentID
        })
        return { ...newState, [key]: unMatched }
      }, {})
    },
  }),
  [makeAComment.toString()]: handleAsync({
    pending: (state, { timestamp, localID, userID, comment }) => {
      const userComments = state[userID] || []
      const newComment = {
        timestamp,
        localID,
        comment,
        pending: 1,
      }
      return {
        ...state,
        [userID]: [...userComments, newComment],
      }
    },
    resolved: (state, { result, localID, userID, mediaFilePath }) => {
      const comments = state[userID] || []
      const { submission_comments } = result.data
      const { id, media_comment: mc } = submission_comments[submission_comments.length - 1]
      const mediaComment = mc ? { ...mc, url: mediaFilePath } : null

      return {
        ...state,
        [userID]: comments.map(
          comment => comment.localID !== localID
            ? comment
            : { ...comment, pending: 0, error: undefined, commentID: id, mediaComment }
        ),
      }
    },
    rejected: (state, { userID, localID, error }) => {
      error = parseErrorMessage(error)
      const comments = state[userID] || []
      PushNotifications.scheduleLocalNotification({
        title: i18n('Comment Failed'),
        body: i18n('Your submission comment failed to send.'),
        identifier: localID,
        fireDate: 1, // seconds
      })
      return {
        ...state,
        [userID]: comments.map(
          comment => comment.localID !== localID
            ? comment
            : { ...comment, error, pending: 0 }
        ),
      }
    },
  }),
  [deletePendingComment.toString()]: (state, { payload }) => {
    return {
      ...state,
      [payload.userID]: state[payload.userID].filter(comment => comment.localID !== payload.localID),
    }
  },
}, {})

export default pendingComments
