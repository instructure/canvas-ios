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
const { refreshDiscussionEntries, createEntry, editEntry, deleteDiscussionEntry, deletePendingReplies, markAllAsRead } = DetailsActions
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
      const replies = r[index].replies
      r[index] = Object.assign(reply, r[index])
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
    resolved: (state, { result: { data } }) => ({
      ...state,
      refs: [...state.refs, data.id],
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
    resolved: (state, { result: [discussionView, discussion], courseID, discussionID }) => {
      let entity = { ...state[discussionID] } || {}
      entity.data = entity.data || {}
      if (entity.data) {
        let participantsAsMap = discussionView.data.participants.reduce((map, p) => ({ ...map, [p.id]: p }), {})
        let replies = discussionView.data.view
        let newEntries = discussionView.data.new_entries || []
        let pendingReplies = { ...(entity.pendingReplies || {}) }

        let pendingReplyKeys = Object.keys(pendingReplies)
        for (let i = 0; i < pendingReplyKeys.length; i++) {
          let reply = pendingReplies[pendingReplyKeys[i]]
          if (reply && reply.data.deleted) {
            replies = deleteReply(reply.localIndexPath, { replies: replies })
          } else {
            replies = addOrUpdateReply(reply.data, reply.localIndexPath, { replies }, Boolean(!reply.data.editor_id), entity.data.discussion_type)
          }

          if (reply && !newEntriesContainsReply(newEntries, reply.data)) {
            delete pendingReplies[pendingReplyKeys[i]]
          }
        }

        entity.data = { ...entity.data, replies: replies, participants: participantsAsMap }
        entity.pendingReplies = pendingReplies
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
    resolved: (state, { result: { data } }) => ({
      ...state,
      [data.id]: {
        data,
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
        data,
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
        replies: {
          ...(state[discussionID] && state[discussionID].replies),
          new: {
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
          new: {
            pending: 0,
            error: parseErrorMessage(error),
          },
        },
      },
    }),
    resolved: (state, { discussionID, result, parentIndexPath }) => {
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
          pendingReplies: { [result.data.id]: { localIndexPath: parentIndexPath, data: Object.assign({ replies: [] }, result.data) } },
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
    resolved: (state, { discussionID, result, parentIndexPath }) => {
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
          pendingReplies: { [result.data.id]: { localIndexPath: parentIndexPath, data: result.data } },
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
