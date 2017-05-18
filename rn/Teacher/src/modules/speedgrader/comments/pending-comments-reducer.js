// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../../utils/handleAsync'
import SubmissionActions from '../../submissions/list/actions'
import { parseErrorMessage } from '../../../redux/middleware/error-handler'

const { makeAComment } = Actions
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
    resolved: (state, { result, localID, userID }) => {
      const comments = state[userID] || []
      const { submission_comments } = result.data
      const commentID = submission_comments[submission_comments.length - 1].id
      return {
        ...state,
        [userID]: comments.map(
          comment => comment.localID !== localID
            ? comment
            : { ...comment, pending: 0, error: undefined, commentID }
        ),
      }
    },
    rejected: (state, { userID, localID, error }) => {
      error = parseErrorMessage(error)
      const comments = state[userID] || []
      return {
        ...state,
        [userID]: comments.map(
          comment => comment.localID !== localID
            ? comment
            : { ...comment, error, pending: comment.pending - 1 }
        ),
      }
    },
  }),
}, {})

export default pendingComments
