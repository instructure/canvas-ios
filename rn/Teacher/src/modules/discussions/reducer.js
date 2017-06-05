/* @flow */

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { default as ListActions } from './list/actions'
import { default as DetailsActions } from './details/actions'
import { default as AnnouncementListActions } from '../announcements/list/actions'
import i18n from 'format-message'

const { refreshDiscussions } = ListActions
const { refreshDiscussionEntries } = DetailsActions
const { refreshAnnouncements } = AnnouncementListActions

export const refs: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshDiscussions.toString(),
  i18n('There was a problem loading discussions.'),
  ({ result }) => result.data.map(discussion => discussion.id)
)

const handleAsyncDiscussions = handleAsync({
  resolved: (state, { result }) => {
    const incoming = result.data
      .reduce((incoming, discussion) => ({
        ...incoming,
        [discussion.id]: {
          data: discussion,
          pending: 0,
          error: null,
        },
      }), {})
    return { ...state, ...incoming }
  },
})

export const discussionData: Reducer<DiscussionState, any> = handleActions({
  [refreshDiscussions.toString()]: handleAsyncDiscussions,
  [refreshAnnouncements.toString()]: handleAsyncDiscussions,
  [refreshDiscussionEntries.toString()]: handleAsync({
    resolved: (state, { result, courseID, discussionID }) => {
      let entity = { ...state[discussionID] } || {}
      entity.data = entity.data || {}
      if (entity.data) {
        let participantsAsMap = result.data.participants.reduce((map, p) => ({ ...map, [p.id]: p }), {})
        entity.data = { ...entity.data, replies: result.data.view, participants: participantsAsMap }
      }
      return {
        ...state,
        [discussionID]: {
          ...entity,
          pending: state[discussionID] && state[discussionID].pending ? state[discussionID].pending - 1 : 0,
          error: null,
        },
      }
    },
  }),
}, {})

export function discussions (state: any = {}, action: any): any {
  let newState = state
  return discussionData(newState, action)
}
