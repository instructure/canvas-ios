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

import { refs, discussions, addOrUpdateReply } from '../reducer'
import { default as ListActions } from '../list/actions'
import { default as DetailActions } from '../details/actions'
import { default as AnnouncementListActions } from '../../announcements/list/actions'
import { default as EditActions } from '../edit/actions'

const { refreshDiscussions } = ListActions
const {
  refreshDiscussionEntries,
  refreshSingleDiscussion,
  createEntry, editEntry,
  deleteDiscussionEntry,
  deletePendingReplies,
  markAllAsRead,
  markEntryAsRead,
} = DetailActions
const { refreshAnnouncements } = AnnouncementListActions
const {
  createDiscussion,
  deletePendingNewDiscussion,
  updateDiscussion,
  deleteDiscussion,
  subscribeDiscussion,
} = EditActions

const template = {
  ...require('../../../__templates__/discussion'),
  ...require('../../../__templates__/file'),
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/section'),
  ...require('../../../__templates__/error'),
  ...require('../../../__templates__/users'),
}

describe('refs', () => {
  describe('refreshDiscussions', () => {
    const data = [
      template.discussion({ id: '1' }),
      template.discussion({ id: '2' }),
    ]

    const pending = {
      type: refreshDiscussions.toString(),
      pending: true,
    }

    it('handles pending', () => {
      expect(refs(undefined, pending)).toEqual({ refs: [], pending: 1 })
    })

    it('handles resolved', () => {
      const initialState = refs(undefined, pending)
      const resolved = {
        type: refreshDiscussions.toString(),
        payload: {
          result: {
            data,
          },
        },
      }
      expect(refs(initialState, resolved)).toEqual({
        pending: 0,
        refs: ['1', '2'],
      })
    })

    it('handles rejected', () => {
      const initialState = refs(undefined, pending)
      const rejected = {
        type: refreshDiscussions.toString(),
        error: true,
        payload: {
          error: template.error('User not authorized'),
        },
      }
      expect(refs(initialState, rejected)).toEqual({ refs: [], pending: 0, error: `There was a problem loading discussions.

User not authorized` })
    })
  })

  describe('deleteDiscussion', () => {
    it('removes the ref', () => {
      const initialState = {
        pending: 0,
        refs: ['4', '44'],
      }
      const resolved = {
        type: deleteDiscussion.toString(),
        payload: {
          discussionID: '44',
        },
      }
      expect(
        refs(initialState, resolved)
      ).toEqual({
        pending: 0,
        refs: ['4'],
      })
    })
  })

  describe('createDiscussion', () => {
    const params = template.createDiscussionParams()
    const discussion = template.discussion({ id: '11', ...params })
    const pending = {
      type: createDiscussion.toString(),
      pending: true,
      payload: {
        params,
        handlesError: true,
      },
    }

    it('handles pending', () => {
      expect(
        refs(undefined, pending)
      ).toEqual({
        pending: 0,
        refs: [],
        new: {
          id: null,
          pending: 1,
          error: null,
        },
      })
    })

    it('handles resolved', () => {
      const initialState = refs(undefined, pending)
      const resolved = {
        type: createDiscussion.toString(),
        payload: {
          result: { data: discussion },
          params,
          handlesError: true,
        },
      }
      expect(refs(initialState, resolved)).toEqual({
        refs: [discussion.id],
        pending: 0,
        new: {
          id: discussion.id,
          pending: 0,
          error: null,
        },
      })
    })

    it('does not insert announcement refs', () => {
      const initialState = refs(undefined, pending)
      const resolved = {
        type: createDiscussion.toString(),
        payload: {
          result: { data: discussion },
          params: template.createDiscussionParams({ is_announcement: true }),
          handlesError: true,
        },
      }
      expect(refs(initialState, resolved)).toEqual({
        refs: [],
        pending: 0,
        new: {
          id: discussion.id,
          pending: 0,
          error: null,
        },
      })
    })

    it('handles rejected', () => {
      const initialState = refs(undefined, pending)
      const rejected = {
        type: createDiscussion.toString(),
        error: true,
        payload: {
          error: template.error('User not authorized'),
        },
      }
      expect(
        refs(initialState, rejected)
      ).toEqual({
        refs: [],
        pending: 0,
        new: {
          pending: 0,
          error: 'User not authorized',
          id: null,
        },
      })
    })
  })

  describe('deletePendingNewDiscussion', () => {
    const initialState = {
      refs: ['1'],
      pending: 0,
      new: {
        pending: 0,
        error: null,
        id: '2',
      },
    }
    const action = {
      type: deletePendingNewDiscussion.toString(),
      courseID: '23',
    }
    expect(
      refs(initialState, action)
    ).toEqual({
      refs: ['1'],
      pending: 0,
      new: null,
    })
  })
})

describe('discussionData', () => {
  it('deletes discussion entry top level', () => {
    let a = template.discussionReply({ id: '1' })
    let b = template.discussionReply({ id: '2' })
    let c = template.discussionReply({ id: '3' })

    let discussion = template.discussionReply({ id: '1', replies: [a, b, c] })
    let localIndexPath = [1]

    const resolved = {
      type: deleteDiscussionEntry.toString(),
      payload: {
        discussionID: '1',
        entryID: '2',
        localIndexPath,
      },
    }

    let bMutated = Object.assign({}, b)
    bMutated.deleted = true

    expect(discussions({ [discussion.id]: { data: discussion } }, resolved)).toEqual({
      '1': {
        data: { ...discussion, replies: [a, bMutated, c] },
        pending: 0,
        error: null,
      },
    })
  })

  it('deletes discussion entry 1 level deep', () => {
    let b1 = template.discussionReply({ id: '4' })
    let b2 = template.discussionReply({ id: '5' })

    let a = template.discussionReply({ id: '1' })
    let b = template.discussionReply({ id: '2', replies: [b1, b2] })
    let c = template.discussionReply({ id: '3' })

    let discussion = template.discussion({ id: '1', replies: [a, b, c], discussion_subentry_count: 2 })
    let localIndexPath = [1, 0]

    const resolved = {
      type: deleteDiscussionEntry.toString(),
      payload: {
        discussionID: '1',
        entryID: '4',
        localIndexPath,
      },
    }

    let b1Mutated = Object.assign({}, b1)
    b1Mutated.deleted = true
    let bMutated = Object.assign({}, b)
    bMutated.replies = [b1Mutated, b2]
    let expectedReplies = [a, bMutated, c]

    expect(discussions({ [discussion.id]: { data: discussion } }, resolved)).toEqual({
      '1': {
        data: {
          ...discussion,
          replies: expectedReplies,
        },
        pending: 0,
        error: null,
      },
    })
  })

  it('PENDING deletes discussion entry 1 level deep PENDING', () => {
    let b1 = template.discussionReply({ id: '4' })
    let b2 = template.discussionReply({ id: '5' })

    let a = template.discussionReply({ id: '1' })
    let b = template.discussionReply({ id: '2', replies: [b1, b2] })
    let c = template.discussionReply({ id: '3' })

    let discussion = template.discussion({
      id: '1',
      replies: [a, b, c],
      discussion_subentry_count: 3,
    })
    let localIndexPath = [1, 0]

    const pending = {
      type: deleteDiscussionEntry.toString(),
      pending: true,
      payload: {
        discussionID: '1',
        entryID: '4',
        localIndexPath,
      },
    }

    let actual = discussions({ [discussion.id]: { data: discussion } }, pending)

    expect(actual).toEqual({
      '1': {
        data: {
          ...discussion,
          discussion_subentry_count: 2,
        },
        pendingReplies: {
          [b1.id]: {
            localIndexPath,
            data: { ...b1, deleted: true },
          },
        },
        pending: 1,
        error: null,
      },
    })
  })

  it('Rejected delete discussion entry 1 level deep', () => {
    let b1 = template.discussionReply({ id: '4' })
    let b2 = template.discussionReply({ id: '5' })

    let a = template.discussionReply({ id: '1' })
    let b = template.discussionReply({ id: '2', replies: [b1, b2] })
    let c = template.discussionReply({ id: '3' })

    let discussion = template.discussion({
      id: '1',
      replies: [a, b, c],
      discussion_subentry_count: 1,
    })
    let localIndexPath = [1, 0]

    const rejected = {
      type: deleteDiscussionEntry.toString(),
      error: true,
      payload: {
        error: { data: { errors: [{ message: 'Wat' }] } },
        discussionID: '1',
        entryID: '4',
        localIndexPath,
      },
    }

    let actual = discussions({ [discussion.id]: { data: discussion } }, rejected)

    expect(actual).toEqual({
      '1': {
        data: {
          ...discussion,
          discussion_subentry_count: 2,
        },
        pendingReplies: {},
        pending: 0,
        error: 'Wat',
      },
    })
  })
})

describe('refreshDiscussions', () => {
  it('handles resolved', () => {
    const one = template.discussion({ id: '1' })
    const two = template.discussion({ id: '2' })
    const resolved = {
      type: refreshDiscussions.toString(),
      payload: {
        result: {
          data: [one, two],
        },
      },
    }

    expect(discussions({}, resolved)).toEqual({
      '1': {
        data: one,
        pending: 0,
        error: null,
      },
      '2': {
        data: two,
        pending: 0,
        error: null,
      },
    })
  })

  it('preserves replies', () => {
    const discussion = template.discussion({
      id: '1',
      message: 'initial message',
    })
    const replies = [template.discussionReply()]
    const initialState = {
      '1': {
        data: { ...discussion, replies },
        error: null,
        pending: 0,
      },
    }
    const expected = {
      '1': {
        data: {
          ...discussion,
          replies,
          message: 'updated message',
        },
        error: null,
        pending: 0,
      },
    }
    const resolved = {
      type: refreshDiscussions.toString(),
      payload: {
        result: {
          data: [{ ...discussion, message: 'updated message' }],
        },
      },
    }
    expect(discussions(initialState, resolved)).toEqual(expected)
  })
})

describe('markEntryAsRead', () => {
  it('updates unread_entries', () => {
    let discussion = template.discussion()
    let state = {
      [discussion.id]: {
        data: discussion,
        unread_entries: ['1'],
      },
    }
    let action = {
      type: markEntryAsRead.toString(),
      payload: {
        discussionID: discussion.id,
        entryID: '1',
      },
    }

    expect(discussions(state, action)).toMatchObject({
      [discussion.id]: {
        data: discussion,
        unread_entries: [],
      },
    })
  })
})

describe('markAllAsRead', () => {
  it('updates unread_count optimistically', () => {
    let discussion = template.discussion({ unread_count: 2 })
    let state = {
      [discussion.id]: {
        data: discussion,
      },
    }
    let action = {
      type: markAllAsRead.toString(),
      pending: true,
      payload: {
        courseID: '1',
        discussionID: discussion.id,
        oldUnreadCount: 2,
      },
    }

    expect(discussions(state, action)).toMatchObject({
      [discussion.id]: {
        data: {
          unread_count: 0,
        },
      },
    })
  })

  it('reverts on error', () => {
    let discussion = template.discussion({ unread_count: 0 })
    let state = {
      [discussion.id]: {
        data: discussion,
      },
    }
    let action = {
      type: markAllAsRead.toString(),
      error: true,
      payload: {
        courseID: '1',
        discussionID: discussion.id,
        oldUnreadCount: 2,
      },
    }

    expect(discussions(state, action)).toMatchObject({
      [discussion.id]: {
        data: {
          unread_count: 2,
        },
      },
    })
  })
})

describe('refreshSingleDiscussion', () => {
  it('returns correct data', () => {
    let discussion = template.discussion({ unread_count: 2 })
    let state = {
      [discussion.id]: {
        data: discussion,
      },
    }

    let actionRefresh = {
      type: refreshSingleDiscussion.toString(),
      payload: {
        courseID: '1',
        result: {
          data: template.discussion({ unread_count: 0 }),
        },
        discussionID: discussion.id,
      },
    }
    expect(discussions(state, actionRefresh)).toEqual({
      [discussion.id]: {
        data: {
          ...template.discussion(),
          unread_count: 0,
        },
      },
    })
  })

  it('doesnt overwrite data in the discussion that already exists', () => {
    let section = template.section()
    let discussion = template.discussion({ sections: [section] })
    let state = {
      [discussion.id]: {
        data: discussion,
      },
    }

    let actionRefresh = {
      type: refreshSingleDiscussion.toString(),
      payload: {
        courseID: '1',
        result: {
          data: template.discussion(),
        },
        discussionID: discussion.id,
      },
    }
    expect(discussions(state, actionRefresh)).toEqual({
      [discussion.id]: {
        data: discussion,
      },
    })
  })
})

describe('refreshDiscussionEntries', () => {
  it('handles resolved with existing discussion', () => {
    let participantA = template.userDisplay({ id: '1', display_name: 'A' })
    let participantB = template.userDisplay({ id: '2', display_name: 'B' })
    let view = template.discussionView({
      participants: [participantA, participantB],
      entry_ratings: {
        '4': 1,
      },
    })
    let stateDiscussion = template.discussion({})
    let expected = template.discussion({})

    const resolved = {
      type: refreshDiscussionEntries.toString(),
      payload: {
        result: [
          {
            data: view,
          },
          {
            data: stateDiscussion,
          },
        ],
        courseID: '2',
        discussionID: '1',
      },
    }

    expected.participants = { [participantA.id]: participantA, [participantB.id]: participantB }
    expected.replies = view.view

    const initialState = {
      [stateDiscussion.id]: {
        data: stateDiscussion,
        unread_entries: template.discussionView().unread_entries,
        entry_ratings: {},
      },
    }

    expect(discussions(initialState, resolved)).toEqual({
      '1': {
        data: expected,
        pendingReplies: {},
        unread_entries: template.discussionView().unread_entries,
        entry_ratings: { '4': 1 },
        pending: 0,
        error: null,
        initialPostRequired: false,
      },
    })
  })

  it('handles resolved with pre-existing deleted entries and existing record in new entries', () => {
    let participantA = template.userDisplay({ id: '1', display_name: 'A' })
    let participantB = template.userDisplay({ id: '2', display_name: 'B' })
    let reply = template.discussionReply({ id: 1 })
    let view = template.discussionView({ view: [reply], participants: [participantA, participantB], new_entries: [template.discussionReply({ id: 1, deleted: true })] })

    let stateDiscussion = template.discussion({})
    let expected = template.discussion({})

    const resolved = {
      type: refreshDiscussionEntries.toString(),
      payload: {
        result: [
          {
            data: view,
          },
          {
            data: stateDiscussion,
          },
        ],
        courseID: '2',
        discussionID: '1',
      },
    }

    let pendingReply = template.discussionReply({ id: 1, deleted: true })
    let pending = { [pendingReply.id]: { data: pendingReply, localIndexPath: [0] } }

    expected.participants = { [participantA.id]: participantA, [participantB.id]: participantB }
    expected.replies = [pendingReply]

    expect(discussions({ [stateDiscussion.id]: { data: stateDiscussion, pendingReplies: pending } }, resolved)).toEqual({
      '1': {
        data: expected,
        pending: 0,
        error: null,
        pendingReplies: pending,
        unread_entries: template.discussionView().unread_entries,
        entry_ratings: template.discussionView().entry_ratings,
        initialPostRequired: false,
      },
    })
  })

  it('handles resolved with pending added entries that was just moved to cached api response (out of new entries)', () => {
    let participantA = template.userDisplay({ id: '1', display_name: 'A' })
    let participantB = template.userDisplay({ id: '2', display_name: 'B' })
    let reply = template.discussionReply({ id: 1 })
    let view = template.discussionView({ view: [reply], participants: [participantA, participantB], new_entries: [] })

    let stateDiscussion = template.discussion({})
    let expected = template.discussion({})

    const resolved = {
      type: refreshDiscussionEntries.toString(),
      payload: {
        result: [
          {
            data: view,
          },
          {
            data: stateDiscussion,
          },
        ],
        courseID: '2',
        discussionID: '1',
      },
    }

    let pendingReply = template.discussionReply({ id: 1 })
    let pending = { [pendingReply.id]: { data: pendingReply, localIndexPath: [] } }

    expected.participants = { [participantA.id]: participantA, [participantB.id]: participantB }
    expected.replies = [pendingReply]

    expect(discussions({ [stateDiscussion.id]: { data: stateDiscussion, pendingReplies: pending } }, resolved)).toEqual({
      '1': {
        data: expected,
        pending: 0,
        error: null,
        pendingReplies: {},
        unread_entries: template.discussionView().unread_entries,
        entry_ratings: template.discussionView().entry_ratings,
        initialPostRequired: false,
      },
    })
  })

  it('handles resolved with pre-existing deleted entries but no existing record in new entries', () => {
    let participantA = template.userDisplay({ id: '1', display_name: 'A' })
    let participantB = template.userDisplay({ id: '2', display_name: 'B' })
    let reply = template.discussionReply({ id: 1, deleted: true })
    let view = template.discussionView({ view: [reply], participants: [participantA, participantB] })
    let stateDiscussion = template.discussion({})
    let expected = template.discussion({})

    const resolved = {
      type: refreshDiscussionEntries.toString(),
      payload: {
        result: [
          {
            data: view,
          },
          {
            data: stateDiscussion,
          },
        ],
        courseID: '2',
        discussionID: '1',
      },
    }

    let pendingReply = template.discussionReply({ id: 1, deleted: true })
    let pending = { [pendingReply.id]: { data: pendingReply, localIndexPath: [0] } }

    expected.participants = { [participantA.id]: participantA, [participantB.id]: participantB }
    expected.replies = [pendingReply]

    expect(discussions({ [stateDiscussion.id]: { data: stateDiscussion, pendingReplies: pending } }, resolved)).toEqual({
      '1': {
        data: expected,
        pendingReplies: {},
        unread_entries: template.discussionView().unread_entries,
        entry_ratings: template.discussionView().entry_ratings,
        pending: 0,
        error: null,
        initialPostRequired: false,
      },
    })
  })

  it('handles rejected when initial post required', () => {
    const action = {
      type: refreshDiscussionEntries.toString(),
      error: true,
      payload: {
        discussionID: '1',
        error: {
          response: { status: 403 },
        },
      },
    }
    const result = discussions({}, action)
    expect(result).toMatchObject({
      '1': { initialPostRequired: true },
    })
  })

  it('handles resolved with edited entries and existing record in new entries', () => {
    let participantA = template.userDisplay({ id: '1', display_name: 'A' })
    let participantB = template.userDisplay({ id: '2', display_name: 'B' })
    let reply = template.discussionReply({ id: 1 })
    let view = template.discussionView({ view: [reply], participants: [participantA, participantB], new_entries: [template.discussionEditReply({ id: 1 })] })

    let stateDiscussion = template.discussion({})
    let expected = template.discussion({})

    const resolved = {
      type: refreshDiscussionEntries.toString(),
      payload: {
        result: [
          {
            data: view,
          },
          {
            data: stateDiscussion,
          },
        ],
        courseID: '2',
        discussionID: '1',
      },
    }

    let pendingReply = template.discussionEditReply({ id: 1 })
    let pending = { [pendingReply.id]: { data: pendingReply, localIndexPath: [0] } }

    expected.participants = { [participantA.id]: participantA, [participantB.id]: participantB }
    expected.replies = [pendingReply]

    expect(discussions({ [stateDiscussion.id]: { data: stateDiscussion, pendingReplies: pending } }, resolved)).toEqual({
      '1': {
        data: expected,
        pending: 0,
        error: null,
        pendingReplies: pending,
        unread_entries: template.discussionView().unread_entries,
        entry_ratings: template.discussionView().entry_ratings,
        initialPostRequired: false,
      },
    })
  })

  it('refreshes assignment disucssion', () => {
    let participantA = template.userDisplay({ id: 1, display_name: 'A' })
    let participantB = template.userDisplay({ id: 2, display_name: 'B' })
    let view = template.discussionView({ participants: [participantA, participantB] })
    let assignment = template.assignment({ id: '123456789' })
    let stateDiscussion = template.discussion({ assignment: assignment })
    let expected = template.discussion({ assignment: assignment })

    const resolved = {
      type: refreshDiscussionEntries.toString(),
      payload: {
        result: [
          {
            data: view,
          },
          {
            data: stateDiscussion,
          },
          {
            data: assignment,
          },
        ],
        courseID: '2',
        discussionID: '1',
      },
    }

    expected.participants = { [participantA.id]: participantA, [participantB.id]: participantB }
    expected.replies = view.view

    expect(discussions({ [stateDiscussion.id]: { data: stateDiscussion } }, resolved)).toEqual({
      '1': {
        data: expected,
        pendingReplies: {},
        unread_entries: template.discussionView().unread_entries,
        entry_ratings: template.discussionView().entry_ratings,
        pending: 0,
        error: null,
        initialPostRequired: false,
      },
    })
  })
})

describe('refreshAnnouncements', () => {
  it('handles resolved', () => {
    const one = template.discussion({ id: '1' })
    const two = template.discussion({ id: '2' })
    const resolved = {
      type: refreshAnnouncements.toString(),
      payload: { result: { data: [one, two] } },
    }

    expect(
      discussions({}, resolved)
    ).toEqual({
      '1': {
        data: one,
        pending: 0,
        error: null,
      },
      '2': {
        data: two,
        pending: 0,
        error: null,
      },
    })
  })
})

describe('createDiscussion', () => {
  it('handles resolved', () => {
    const discussion = template.discussion({ id: '2' })
    const initialState = {
      '1': {
        data: template.discussion({ id: '1' }),
        pending: 0,
        error: null,
      },
    }
    const resolved = {
      type: createDiscussion.toString(),
      payload: {
        result: { data: discussion, params: discussion },
        params: template.createDiscussionParams(),
      },
    }

    expect(
      discussions(initialState, resolved)
    ).toEqual({
      ...initialState,
      '2': {
        data: discussion,
        pending: 0,
        error: null,
      },
    })
  })

  it('attaches sections to the discussion', () => {
    const sections = [template.section()]
    const discussion = template.discussion({
      id: '2',
      is_section_specific: true,
      sections,
    })
    const initialState = {}
    const resolved = {
      type: createDiscussion.toString(),
      payload: {
        result: { data: discussion },
        params: template.createDiscussionParams({ sections }),
      },
    }

    expect(
      discussions(initialState, resolved)['2'].data.sections
    ).toEqual(sections)
  })
})

describe('updateDiscussion', () => {
  it('handles pending', () => {
    const params = template.updateDiscussionParams({ id: '45' })
    const discussion = template.discussion({ id: '45' })
    const initialState = {
      '45': {
        data: discussion,
        pending: 0,
        error: null,
      },
    }
    const pending = {
      type: updateDiscussion.toString(),
      pending: true,
      payload: {
        params,
        handlesError: true,
        courseID: '1',
      },
    }
    expect(
      discussions(initialState, pending)
    ).toEqual({
      '45': {
        data: discussion,
        pending: 1,
        error: null,
      },
    })
  })

  it('handles resolved', () => {
    const discussion = template.discussion({ id: '35' })
    const params = template.updateDiscussionParams({ id: '35' })
    const initialState = {
      '35': {
        data: discussion,
        pending: 1,
        error: null,
      },
    }
    const resolved = {
      type: updateDiscussion.toString(),
      payload: {
        result: { data: discussion },
        params,
        handlesError: true,
        courseID: '3',
      },
    }

    expect(
      discussions(initialState, resolved)
    ).toEqual({
      ...initialState,
      '35': {
        data: discussion,
        pending: 0,
        error: null,
      },
    })
  })

  it('handles rejected', () => {
    const discussion = template.discussion({ id: '25' })
    const params = template.updateDiscussionParams({ id: '25' })
    const initialState = {
      '25': {
        data: discussion,
        pending: 1,
        error: null,
      },
    }
    const rejected = {
      type: updateDiscussion.toString(),
      error: true,
      payload: {
        error: { data: { errors: [{ message: 'Wat' }] } },
        params,
        handlesError: true,
        courseID: '1',
      },
    }
    expect(
      discussions(initialState, rejected)
    ).toEqual({
      '25': {
        data: discussion,
        error: 'Wat',
        pending: 0,
      },
    })
  })

  it('attaches sections to the discussion', () => {
    let sections = [template.section()]
    const discussion = template.discussion({ id: '35' })
    const params = template.updateDiscussionParams({
      id: '35',
      is_section_specific: true,
      sections,
    })
    const initialState = {}
    const resolved = {
      type: updateDiscussion.toString(),
      payload: {
        result: { data: discussion },
        params,
        handlesError: true,
        courseID: '3',
      },
    }

    expect(
      discussions(initialState, resolved)['35'].data.sections
    ).toEqual(sections)
  })
})

describe('deleteDiscussion', () => {
  it('handles pending', () => {
    const discussion = template.discussion({ id: '45' })
    const initialState = {
      '45': {
        data: discussion,
        pending: 0,
        error: null,
      },
    }
    const pending = {
      type: deleteDiscussion.toString(),
      pending: true,
      payload: {
        discussionID: '45',
        handlesError: true,
        courseID: '1',
      },
    }
    expect(
      discussions(initialState, pending)
    ).toEqual({
      '45': {
        data: discussion,
        pending: 1,
        error: null,
      },
    })
  })

  it('handles resolved', () => {
    const discussion = template.discussion({ id: '35' })
    const initialState = {
      '35': {
        data: discussion,
        pending: 1,
        error: null,
      },
    }
    const resolved = {
      type: deleteDiscussion.toString(),
      payload: {
        result: { data: discussion },
        discussionID: '35',
        handlesError: true,
        courseID: '3',
      },
    }

    expect(
      discussions(initialState, resolved)
    ).toEqual({})
  })

  it('handles rejected', () => {
    const discussion = template.discussion({ id: '25' })
    const initialState = {
      '25': {
        data: discussion,
        pending: 1,
        error: null,
      },
    }
    const rejected = {
      type: deleteDiscussion.toString(),
      error: true,
      payload: {
        error: { data: { errors: [{ message: 'Wat' }] } },
        discussionID: '25',
        handlesError: true,
        courseID: '1',
      },
    }
    expect(
      discussions(initialState, rejected)
    ).toEqual({
      '25': {
        data: discussion,
        error: 'Wat',
        pending: 0,
      },
    })
  })
})

describe('subscribeDiscussion', () => {
  it('should set subscribed in pending', () => {
    const discussion = template.discussion({ id: '1', subscribed: false })
    const initialState = {
      '1': {
        data: discussion,
        pending: 0,
        error: null,
      },
    }
    const pending = {
      type: subscribeDiscussion.toString(),
      pending: true,
      payload: {
        discussionID: '1',
        courseID: '1',
        subscribed: true,
      },
    }
    expect(
      discussions(initialState, pending)
    ).toEqual({
      '1': {
        data: { ...discussion, subscribed: true },
        pending: 0,
        error: null,
      },
    })
  })

  it('should revert subscribed in rejected', () => {
    const discussion = template.discussion({ id: '1', subscribed: false })
    const initialState = {
      '1': {
        data: { ...discussion, subscribed: true },
        pending: 0,
        error: null,
      },
    }
    const rejected = {
      type: subscribeDiscussion.toString(),
      error: true,
      payload: {
        discussionID: '1',
        courseID: '1',
        subscribed: true,
      },
    }
    expect(
      discussions(initialState, rejected)
    ).toEqual({
      '1': {
        data: discussion,
        pending: 0,
        error: null,
      },
    })
  })
})

describe('createEntry', () => {
  it('handles resolved', () => {
    const reply = template.discussionReply({ id: '1' })
    const pendingReply = template.discussionReply({ id: '3' })
    let expectedReply = Object.assign({}, reply)
    const initialState = {
      '1': {
        pending: 0,
        error: null,
        data: template.discussion({ id: '1' }),
      },
      '2': {
        pending: 1,
        error: 'SOMETHING HAPPENED',
        data: template.discussion({
          id: '2',
          replies: [
            reply,
          ],
        }),
        replies: {
          new: {
            pending: 2,
            error: 'WAT',
          },
        },
        pendingReplies: { [pendingReply.id]: { localIndexPath: [0], data: pendingReply } },
      },
    }
    const resolved = {
      type: createEntry.toString(),
      payload: {
        discussionID: '2',
        result: { data: reply },
      },
    }
    expect(
      discussions(initialState, resolved)
    ).toEqual({
      ...initialState,
      '2': {
        data: {
          ...template.discussion({ id: '2' }),
          replies: [template.discussionReply({ id: '1' })],
        },
        pending: 1,
        error: 'SOMETHING HAPPENED',
        replies: {
          new: {
            pending: 0,
            error: null,
          },
        },
        pendingReplies: { [pendingReply.id]: { localIndexPath: [0], data: pendingReply }, [reply.id]: { data: expectedReply } },
      },
    })
  })

  it('handles pending', () => {
    const lastReplyAt = new Date(0)
    const discussion = template.discussion({
      id: '2',
      discussion_subentry_count: 1,
      last_reply_at: lastReplyAt.toISOString(),
    })
    const initialState = {
      '1': {
        pending: 0,
        error: null,
        data: template.discussion({ id: '1' }),
      },
      '2': {
        pending: 1,
        error: 'SOMETHING HAPPENED',
        data: discussion,
        replies: {
          new: {
            pending: 2,
            error: 'WAT',
          },
        },
      },
    }
    const pending = {
      type: createEntry.toString(),
      pending: true,
      payload: {
        discussionID: '2',
      },
    }
    let newState = discussions(initialState, pending)
    delete discussion.last_reply_at

    expect(newState).toMatchObject({
      ...initialState,
      '2': {
        data: {
          ...discussion,
          discussion_subentry_count: 2,
        },
        pending: 1,
        error: 'SOMETHING HAPPENED',
        replies: {
          new: {
            pending: 1,
            error: null,
          },
        },
      },
    })
    expect(new Date(newState['2'].data.last_reply_at) > lastReplyAt).toEqual(true)
  })

  it('handles rejected', () => {
    let lastReplyAt = new Date()
    const discussion = template.discussion({
      id: '2',
      discussion_subentry_count: 2,
      last_reply_at: lastReplyAt.toISOString(),
    })
    const initialState = {
      '1': {
        pending: 0,
        error: null,
        data: template.discussion({ id: '1' }),
      },
      '2': {
        pending: 1,
        error: 'SOMETHING HAPPENED',
        data: discussion,
        replies: {
          new: {
            pending: 2,
            error: 'WAT',
          },
        },
      },
    }
    const rejected = {
      type: createEntry.toString(),
      error: true,
      payload: {
        discussionID: '2',
        error: template.error('User not authorized'),
        lastReplyAt: (new Date(0)).toISOString(),
      },
    }
    expect(
      discussions(initialState, rejected)
    ).toEqual({
      ...initialState,
      '2': {
        data: {
          ...discussion,
          discussion_subentry_count: 1,
          last_reply_at: (new Date(0)).toISOString(),
        },
        pending: 1,
        error: 'SOMETHING HAPPENED',
        replies: {
          new: {
            pending: 0,
            error: 'User not authorized',
          },
        },
      },
    })
  })

  it('addOrUpdateReply ADD reply 1 deep side_comment discussion', () => {
    let d = template.discussionReply({ id: '4' })
    let c = template.discussionReply({ id: '3' })
    let b = template.discussionReply({ id: '2' })
    let a = template.discussionReply({ id: '1', replies: [c, d] })
    let replies = [a, b]

    let e = template.discussionReply({ id: '5' })
    let localIndexPath = [0, 1]
    let result = addOrUpdateReply(e, localIndexPath, { replies }, true, 'side_comment')

    let aUpdated = template.discussionReply({ id: '1', replies: [c, d, e] })
    let expected = [aUpdated, b]
    expect(result).toEqual(expected)
  })

  it('addOrUpdateReply ADD top_level side_comment discussion', () => {
    let c = template.discussionReply({ id: '3' })
    let b = template.discussionReply({ id: '2' })
    let a = template.discussionReply({ id: '1' })
    let replies = [a, b]

    let localIndexPath = [1]
    let result = addOrUpdateReply(c, localIndexPath, { replies }, true, 'side_comment')

    let cEx = template.discussionReply({ id: '3' })
    let bEx = template.discussionReply({ id: '2', replies: [cEx] })
    let expected = [a, bEx]
    expect(result).toEqual(expected)
  })

  it('addOrUpdateReply ADD reply 1 deep threaded discussion', () => {
    let c = template.discussionReply({ id: '3' })
    let b = template.discussionReply({ id: '2', replies: [c] })
    let a = template.discussionReply({ id: '1' })
    let replies = [a, b]

    let d = template.discussionReply({ id: '4' })
    let localIndexPath = [1, 0]
    let result = addOrUpdateReply(d, localIndexPath, { replies }, true, 'threaded')

    let cEx = template.discussionReply({ id: '3', replies: [d] })
    let bEx = template.discussionReply({ id: '2', replies: [cEx] })
    let expected = [a, bEx]
    expect(result).toEqual(expected)
  })

  it('addOrUpdateReply ADD reply top level', () => {
    let b = template.discussionReply({ id: '2' })
    let a = template.discussionReply({ id: '1' })
    let replies = [a]

    let localIndexPath = []
    let result = addOrUpdateReply(b, localIndexPath, { replies }, true, 'threaded')

    let expected = [a, b]
    expect(result).toEqual(expected)
  })

  it('addOrUpdateReply UPDATE reply top level', () => {
    let b = template.discussionReply({ id: '2', message: 'b' })
    let a = template.discussionReply({ id: '1' })
    let replies = [a, b]

    let localIndexPath = [1]
    let bUpdated = template.discussionReply({ id: '2', message: 'UPDATED' })
    let result = addOrUpdateReply(bUpdated, localIndexPath, { replies }, false, 'threaded')

    let expected = [a, bUpdated]
    expect(result).toEqual(expected)
  })

  it('addOrUpdateReply UPDATE reply 1 deep', () => {
    let c = template.discussionReply({ id: '3', message: 'c' })
    let b = template.discussionReply({ id: '2', replies: [c] })
    let a = template.discussionReply({ id: '1' })
    let replies = [a, b]

    let cUpdated = template.discussionReply({ id: '3', message: 'UPDATED' })
    let localIndexPath = [1, 0]
    let result = addOrUpdateReply(cUpdated, localIndexPath, { replies }, false, 'threaded')

    let expected = [a, b]
    expect(result).toEqual(expected)
  })

  it('addOrUpdateReply UPDATE reply 1 deep not yet in incoming replies', () => {
    let c = template.discussionReply({ id: '3', message: 'BBBB' })
    let a = template.discussionReply({ id: '1' })
    let replies = [a]

    let localIndexPath = [0, 0]
    let result = addOrUpdateReply(c, localIndexPath, { replies }, false, 'side_comment')

    let expected = [template.discussionReply({ id: '1', replies: [c] })]
    expect(result).toEqual(expected)
  })
})

describe('editEntry', () => {
  it('handles resolved', () => {
    const reply = template.discussionEditReply({ id: '1' })
    let expectedReply = Object.assign({}, reply)
    const pendingReply = template.discussionReply({ id: '3' })
    const initialState = {
      '1': {
        pending: 0,
        error: null,
        data: template.discussion({ id: '1' }),
      },
      '2': {
        pending: 1,
        error: 'SOMETHING HAPPENED',
        data: template.discussion({
          id: '2',
          replies: [
            reply,
          ],
        }),
        replies: {
          edit: {
            pending: 2,
            error: 'WAT',
          },
        },
        pendingReplies: { [pendingReply.id]: { localIndexPath: [0], data: pendingReply } },

      },
    }
    const resolved = {
      type: editEntry.toString(),
      payload: {
        discussionID: '2',
        result: { data: reply },
      },
    }
    expect(
      discussions(initialState, resolved)
    ).toEqual({
      ...initialState,
      '2': {
        data: {
          ...template.discussion({ id: '2' }),
          replies: [template.discussionEditReply({ id: '1' })],
        },
        pending: 1,
        error: 'SOMETHING HAPPENED',
        replies: {
          edit: {
            pending: 0,
            error: null,
          },
        },
        pendingReplies: { [pendingReply.id]: { localIndexPath: [0], data: pendingReply }, [reply.id]: { data: expectedReply } },
      },
    })
  })

  it('handles pending', () => {
    const initialState = {
      '1': {
        pending: 0,
        error: null,
        data: template.discussion({ id: '1' }),
      },
      '2': {
        pending: 1,
        error: 'SOMETHING HAPPENED',
        data: template.discussion({ id: '2' }),
        replies: {
          edit: {
            pending: 2,
            error: 'WAT',
          },
        },
      },
    }
    const pending = {
      type: editEntry.toString(),
      pending: true,
      payload: {
        discussionID: '2',
      },
    }
    expect(
      discussions(initialState, pending)
    ).toEqual({
      ...initialState,
      '2': {
        data: template.discussion({ id: '2' }),
        pending: 1,
        error: 'SOMETHING HAPPENED',
        replies: {
          edit: {
            pending: 1,
            error: null,
          },
        },
      },
    })
  })

  it('handles rejected', () => {
    const initialState = {
      '1': {
        pending: 0,
        error: null,
        data: template.discussion({ id: '1' }),
      },
      '2': {
        pending: 1,
        error: 'SOMETHING HAPPENED',
        data: template.discussion({ id: '2' }),
        replies: {
          edit: {
            pending: 2,
            error: 'WAT',
          },
        },
      },
    }
    const rejected = {
      type: editEntry.toString(),
      error: true,
      payload: {
        discussionID: '2',
        error: template.error('User not authorized'),
      },
    }
    expect(
      discussions(initialState, rejected)
    ).toEqual({
      ...initialState,
      '2': {
        data: template.discussion({ id: '2' }),
        pending: 1,
        error: 'SOMETHING HAPPENED',
        replies: {
          edit: {
            pending: 0,
            error: 'User not authorized',
          },
        },
      },
    })
  })
})

describe('deletePendingReplies', () => {
  const initialState = {
    '1': {
      pending: 0,
      error: null,
      data: template.discussion({ id: '1' }),
    },
    '2': {
      pending: 1,
      error: 'SOMETHING HAPPENED',
      data: template.discussion({ id: '2' }),
      replies: {
        edit: {
          pending: 2,
          error: 'WAT',
        },
      },
    },
  }
  const action = {
    type: deletePendingReplies.toString(),
    discussionID: '2',
  }
  expect(refs(initialState, action)).toEqual({
    ...initialState,
    '2': {
      pending: 1,
      error: 'SOMETHING HAPPENED',
      data: template.discussion({ id: '2' }),
      replies: {
        new: null,
        edit: null,
      },
    },
  })
})
