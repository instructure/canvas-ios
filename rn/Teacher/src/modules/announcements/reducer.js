/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { default as ListActions } from './list/actions'
import { default as EditActions } from '../discussions/edit/actions'
import i18n from 'format-message'
import composeReducers from '../../redux/compose-reducers'

const { refreshAnnouncements } = ListActions
const { createDiscussion, deleteDiscussion } = EditActions

const list: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshAnnouncements.toString(),
  i18n('There was a problem loading the announcements.'),
  ({ result }) => result.data.map(announcement => announcement.id)
)

const refsChanges: Reducer<AsyncRefs, any> = handleActions({
  [createDiscussion.toString()]: handleAsync({
    resolved: (state, { result: { data } }) => ({
      ...state,
      refs: [...state.refs, data.id],
    }),
  }),
  [deleteDiscussion.toString()]: handleAsync({
    resolved: (state, { discussionID }) => ({
      ...state,
      refs: (state.refs || []).filter(ref => ref !== discussionID),
    }),
  }),
}, {})

export const refs: Reducer<AsyncRefs, any> = composeReducers(list, refsChanges)
