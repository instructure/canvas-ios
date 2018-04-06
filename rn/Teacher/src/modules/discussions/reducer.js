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

/* @flow */

import { Reducer } from 'redux'
import { asyncRefsReducer } from '../../redux/async-refs-reducer'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { default as ListActions } from './list/actions'
import { default as DetailsActions } from './details/actions'
import { default as AnnouncementListActions } from '../announcements/list/actions'
import { default as EditActions } from './edit/actions'
import i18n from 'format-message'
import composeReducers from '../../redux/compose-reducers'
import { parseErrorMessage } from '../../redux/middleware/error-handler'

const { refreshDiscussions } = ListActions
const {
  refreshDiscussionEntries,
  refreshSingleDiscussion,
  createEntry,
  editEntry,
  deleteDiscussionEntry,
  deletePendingReplies,
  markAllAsRead,
  markEntryAsRead,
} = DetailsActions
const { refreshAnnouncements } = AnnouncementListActions
const {
  createDiscussion,
  deletePendingNewDiscussion,
  updateDiscussion,
  deleteDiscussion,
  subscribeDiscussion,
} = EditActions

const list: Reducer<AsyncRefs, any> = asyncRefsReducer(
  refreshDiscussions.toString(),
  i18n('There was a problem loading discussions.'),
  ({ result }) => result.data.map(discussion => discussion.id)
)

export function replyFromLocalIndexPath (localIndexPath: number[], replies: DiscussionReply[], createNewCopyOfReply: boolean = true): ?DiscussionReply {
  let r = replies
  let reply
  if (!r.length) return reply
  for (let i = 0; i < localIndexPath.length; i++) {
    let index = localIndexPath[i]
    if (i === localIndexPath.length - 1) {
      reply = (createNewCopyOfReply) ? Object.assign({ }, r[index]) : r[index]
    } else {
      r = r[index].replies
    }
  }
  return reply
}

export function deleteReply (localIndexPath: number[], objectWithRepliesProperty: any): DiscussionReply[] {
  let r = objectWithRepliesProperty.replies.slice()
  let result = r

  for (let i = 0; i < localIndexPath.length; i++) {
    let index = localIndexPath[i]
    if (i === localIndexPath.length - 1) {
      r[index] = Object.assign({ deleted: true }, r[index])
    } else {
      r[index] = Object.assign({}, r[index])
      r[index].replies = r[index].replies.slice()
      r = r[index].replies
    }
  }
  return result
}

export function addOrUpdateReply (reply: DiscussionReply, localIndexPath: number[], objectWithRepliesProperty: any, isAdd: boolean, discussionType: DiscussionType): DiscussionReply[] {
  let r = objectWithRepliesProperty.replies.slice()
  let result = r

  //  top level add
  if (isAdd && localIndexPath.length === 0) {
    r.push(reply)
  } else if (isAdd && discussionType === 'side_comment' && localIndexPath.length >= 2) {
    localIndexPath = localIndexPath.slice(0, 1)
  }

  for (let i = 0; i < localIndexPath.length; i++) {
    let index = localIndexPath[i]
    if (!isAdd && i === localIndexPath.length - 1) {
      const replies = r[index] && r[index].replies ? r[index].replies : []
      r[index] = r[index] ? Object.assign(r[index], reply) : { ...reply }
      r[index] = {
        ...r[index],
        replies: replies,
      }
    } else {
      r[index] = Object.assign({}, r[index])
      r[index].replies = (r[index].replies) ? r[index].replies.slice() : []

      if (isAdd && i === localIndexPath.length - 1) {
        r[index].replies.push(reply)
      } else {
        r = r[index].replies
      }
    }
  }
  return result
}

export function newEntriesContainsReply (newEntries: DiscussionReply[], reply: DiscussionReply): boolean {
  for (let i = 0; i < newEntries.length; i++) {
    if (newEntries[i].id === reply.id) {
      return true
    }
  }
  return false
}

const refsChanges: Reducer<AsyncRefs, any> = handleActions({
  [createDiscussion.toString()]: handleAsync({
    pending: (state) => ({
      ...state,
      new: {
        ...state.new,
        pending: 1,
        error: null,
        id: null,
      },
    }),
    resolved: (state, { result: { data }, params }) => ({
      ...state,
      refs: params.is_announcement ? [...state.refs] : [...state.refs, data.id],
      new: {
        ...state.new,
        pending: 0,
        error: null,
        id: data.id,
      },
    }),
    rejected: (state, { error }) => ({
      ...state,
      new: {
        ...state.new,
        pending: 0,
        error: parseErrorMessage(error),
        id: null,
      },
    }),
  }),
  [deleteDiscussion.toString()]: handleAsync({
    resolved: (state, { discussionID }) => ({
      ...state,
      refs: (state.refs || []).filter(ref => ref !== discussionID),
    }),
  }),
  [deletePendingNewDiscussion.toString()]: (state) => ({
    ...state,
    new: null,
  }),
  [deletePendingReplies.toString()]: (state, { discussionID }) => ({
    ...state,
    [discussionID]: {
      ...state[discussionID],
      replies: {
        ...(state[discussionID] && state[discussionID].replies),
        edit: null,
        new: null,
      },
    },
  }),
}, {})

export const refs: Reducer<AsyncRefs, any> = composeReducers(list, refsChanges)

const handleAsyncDiscussions = handleAsync({
  resolved: (state, { result }) => {
    const incoming = result.data
      .reduce((incoming, discussion) => ({
        ...incoming,
        [discussion.id]: {
          data: { ...(state[discussion.id] && state[discussion.id].data), ...discussion },
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
    resolved: (state, { result: [discussionView, discussion], context, contextID, discussionID }) => {
      let entity = { ...state[discussionID] } || {}

      let participantsAsMap = discussionView.data.participants.reduce((map, p) => ({ ...map, [p.id]: p }), {})
      let replies = discussionView.data.view
      let unreadEntries = discussionView.data.unread_entries || []
      let entryRatings = discussionView.data.entry_ratings || {}
      let newEntries = discussionView.data.new_entries || []
      let pendingReplies = { ...(entity.pendingReplies || {}) }

      let pendingReplyKeys = Object.keys(pendingReplies)
      let pendingRepliesNeedingToBeRemoved = []
      for (let i = 0; i < pendingReplyKeys.length; i++) {
        let reply = pendingReplies[pendingReplyKeys[i]]
        if (reply && !reply.data.editor_id && !newEntriesContainsReply(newEntries, reply.data)) {
          pendingRepliesNeedingToBeRemoved.push(pendingReplyKeys[i])
        } else {
          if (reply && reply.data.deleted) {
            replies = deleteReply(reply.localIndexPath, { replies: replies })
          } else {
            replies = addOrUpdateReply(reply.data, reply.localIndexPath, { replies }, Boolean(!reply.data.editor_id), discussion.data.discussion_type)
          }
        }
      }

      pendingRepliesNeedingToBeRemoved.forEach((r) => { delete pendingReplies[r] })

      let existingDiscussion = entity.data || {}
      entity.data = { ...existingDiscussion, ...discussion.data, replies: replies, participants: participantsAsMap }
      entity.pendingReplies = pendingReplies

      return {
        ...state,
        [discussionID]: {
          ...entity,
          pending: state[discussionID] && state[discussionID].pending ? state[discussionID].pending - 1 : 0,
          error: null,
          unread_entries: unreadEntries,
          entry_ratings: entryRatings,
          initialPostRequired: false,
        },
      }
    },
    rejected: (state, { error, discussionID }) => {
      let message = parseErrorMessage(error)
      if (error.response && error.response.status === 403) {
        return {
          ...state,
          [discussionID]: {
            ...state[discussionID],
            initialPostRequired: true,
          },
        }
      }

      return {
        ...state,
        [discussionID]: {
          ...state[discussionID],
          error: message,
        },
      }
    },
  }),
  [refreshSingleDiscussion.toString()]: handleAsync({
    resolved: (state, { result, discussionID }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...state[discussionID].data,
          ...result.data,
        },
      },
    }),
  }),
  [deleteDiscussionEntry.toString()]: handleAsync({
    rejected: (state, { error, discussionID, entryID }) => {
      let entity = { ...state[discussionID] } || {}
      let pendingReplies = entity.pendingReplies || {}
      pendingReplies = { ...pendingReplies }

      delete pendingReplies[entryID]

      entity = {
        ...entity,
        pendingReplies: pendingReplies,
      }

      return {
        ...state,
        [discussionID]: {
          ...entity,
          data: {
            ...entity.data,
            discussion_subentry_count: entity.data.discussion_subentry_count + 1,
          },
          pending: (state[discussionID] && state[discussionID].pending || 1) - 1,
          error: parseErrorMessage(error),
        },
      }
    },
    pending: (state, { courseID, discussionID, entryID, localIndexPath }) => {
      let entity = { ...state[discussionID] } || {}
      let pendingReply = replyFromLocalIndexPath(localIndexPath, entity.data.replies)
      if (pendingReply) { pendingReply.deleted = true; pendingReply.replies = [] }
      let pendingReplies = entity.pendingReplies || {}
      pendingReplies = {
        ...pendingReplies,
        [entryID]: {
          localIndexPath: localIndexPath,
          data: pendingReply,
        },
      }

      entity = {
        ...entity,
        pendingReplies: pendingReplies,
      }

      return {
        ...state,
        [discussionID]: {
          ...entity,
          data: {
            ...entity.data,
            discussion_subentry_count: entity.data.discussion_subentry_count - 1,
          },
          pending: (state[discussionID] && state[discussionID].pending || 0) + 1,
          error: null,
        },
      }
    },
    resolved: (state, { discussionID, entryID, localIndexPath }) => {
      let entity = { ...state[discussionID] } || {}
      let result = deleteReply(localIndexPath, entity.data)
      entity = {
        ...entity,
        data: { ...entity.data, replies: result },
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
  [createDiscussion.toString()]: handleAsync({
    resolved: (state, { params, result: { data } }) => ({
      ...state,
      [data.id]: {
        data: {
          ...data,
          sections: params.sections,
        },
        pending: 0,
        error: null,
      },
    }),
  }),
  [updateDiscussion.toString()]: handleAsync({
    pending: (state, { params }) => ({
      ...state,
      [params.id]: {
        ...state[params.id],
        pending: (state[params.id] && state[params.id].pending || 0) + 1,
        error: null,
      },
    }),
    resolved: (state, { params, result: { data } }) => ({
      ...state,
      [params.id]: {
        ...state[params.id],
        data: {
          ...data,
          sections: params.sections,
        },
        pending: (state[params.id] && state[params.id].pending || 1) - 1,
        error: null,
      },
    }),
    rejected: (state, { params, error }) => ({
      ...state,
      [params.id]: {
        ...state[params.id],
        pending: (state[params.id] && state[params.id].pending || 1) - 1,
        error: parseErrorMessage(error),
      },
    }),
  }),
  [deleteDiscussion.toString()]: handleAsync({
    pending: (state, { discussionID }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        pending: (state[discussionID] && state[discussionID].pending || 0) + 1,
        error: null,
      },
    }),
    resolved: (state, { discussionID }) => {
      return Object.keys(state).reduce((incoming, current) => {
        return current === discussionID ? incoming : { ...incoming, [current]: state[current] }
      }, {})
    },
    rejected: (state, { discussionID, error }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        pending: (state[discussionID] && state[discussionID].pending || 1) - 1,
        error: parseErrorMessage(error),
      },
    }),
  }),
  [createEntry.toString()]: handleAsync({
    pending: (state, { discussionID }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...state[discussionID].data,
          discussion_subentry_count: state[discussionID].data.discussion_subentry_count + 1,
          last_reply_at: (new Date()).toISOString(),
        },
        replies: {
          ...(state[discussionID] && state[discussionID].replies),
          new: {
            pending: 1,
            error: null,
          },
        },

      },
    }),
    rejected: (state, { discussionID, error, lastReplyAt }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...state[discussionID].data,
          discussion_subentry_count: state[discussionID].data.discussion_subentry_count - 1,
          last_reply_at: lastReplyAt,
        },
        replies: {
          ...(state[discussionID] && state[discussionID].replies),
          new: {
            pending: 0,
            error: parseErrorMessage(error),
          },
        },
      },
    }),
    resolved: (state, { discussionID, result, indexPath }) => {
      return {
        ...state,
        [discussionID]: {
          ...state[discussionID],
          replies: {
            ...(state[discussionID] && state[discussionID].replies),
            new: {
              pending: 0,
              error: null,
            },
          },
          pendingReplies: {
            ...(state[discussionID] && state[discussionID].pendingReplies),
            [result.data.id]: { localIndexPath: indexPath, data: Object.assign({ replies: [] }, result.data) },
          },
        },
      }
    },
  }),
  [editEntry.toString()]: handleAsync({
    pending: (state, { discussionID }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        replies: {
          ...(state[discussionID] && state[discussionID].replies),
          edit: {
            pending: 1,
            error: null,
          },
        },

      },
    }),
    rejected: (state, { discussionID, error }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        replies: {
          ...(state[discussionID] && state[discussionID].replies),
          edit: {
            pending: 0,
            error: parseErrorMessage(error),
          },
        },
      },
    }),
    resolved: (state, { discussionID, result, indexPath }) => {
      return {
        ...state,
        [discussionID]: {
          ...state[discussionID],
          replies: {
            ...(state[discussionID] && state[discussionID].replies),
            edit: {
              pending: 0,
              error: null,
            },
          },
          pendingReplies: {
            ...(state[discussionID] && state[discussionID].pendingReplies),
            [result.data.id]: { localIndexPath: indexPath, data: result.data },
          },
        },
      }
    },
  }),
  [subscribeDiscussion.toString()]: handleAsync({
    pending: (state, { discussionID, subscribed }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...(state[discussionID] && state[discussionID].data),
          subscribed,
        },
      },
    }),
    rejected: (state, { discussionID, subscribed }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...(state[discussionID] && state[discussionID].data),
          subscribed: !subscribed,
        },
      },
    }),
  }),
  [markEntryAsRead.toString()]: handleAsync({
    resolved: (state, { discussionID, entryID }) => {
      let unreadEntries = [...state[discussionID].unread_entries || []]
      let index = unreadEntries.indexOf(entryID)
      if (index > -1) unreadEntries.splice(index, 1)
      return {
        ...state,
        [discussionID]: {
          ...state[discussionID],
          unread_entries: unreadEntries,
        },
      }
    },
  }),
  [markAllAsRead.toString()]: handleAsync({
    pending: (state, { discussionID, courseID }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...state[discussionID].data,
          unread_count: 0,
        },
      },
    }),
    rejected: (state, { discussionID, courseID, oldUnreadCount }) => ({
      ...state,
      [discussionID]: {
        ...state[discussionID],
        data: {
          ...state[discussionID].data,
          unread_count: oldUnreadCount,
        },
      },
    }),
  }),
}, {})

export function discussions (state: any = {}, action: any): any {
  return discussionData(state, action)
}
