/* @flow */

import { refs, discussions, mergeDiscussionEntriesWithNewEntries } from '../reducer'
import { default as ListActions } from '../list/actions'
import { default as DetailActions } from '../details/actions'
import { default as AnnouncementListActions } from '../../announcements/list/actions'
import { default as EditActions } from '../edit/actions'

const { refreshDiscussions } = ListActions
const { refreshDiscussionEntries, createEntry } = DetailActions
const { refreshAnnouncements } = AnnouncementListActions
const {
  createDiscussion,
  deletePendingNewDiscussion,
  updateDiscussion,
  deleteDiscussion,
  subscribeDiscussion,
} = EditActions

const template = {
  ...require('../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/error'),
  ...require('../../../api/canvas-api/__templates__/users'),
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
  it('mergeDiscussionEntriesWithNewEntries for top level reply (no parent)', () => {
    let r = template.discussionReply({ id: '1' })
    let rr = template.discussionReply({ id: '2' })
    let a = template.discussionReply({ id: '11', replies: [r, r] })
    let result = mergeDiscussionEntriesWithNewEntries([a], [rr])

    expect(result).toEqual([ a, rr ])
  })

  it('mergeDiscussionEntriesWithNewEntries for nested reply', () => {
    let r = template.discussionReply({ id: '1' })
    let rr = template.discussionReply({ id: '2' })
    let rrr = template.discussionReply({ id: '3', parent_id: '2' })
    let a = template.discussionReply({ id: '11', replies: [r, rr] })
    let expected = template.discussionReply({ id: '2', replies: [rrr] })
    let expectedA = template.discussionReply({ id: '11', replies: [r, expected] })
    let result = mergeDiscussionEntriesWithNewEntries([a], [rrr])

    expect(result).toEqual([
      expectedA,
    ])
  })
  it('mergeDiscussionEntriesWithNewEntries for top level reply (no parent)', () => {
    let r = template.discussionReply({ id: '1' })
    let rr = template.discussionReply({ id: '2' })
    let a = template.discussionReply({ id: '11', replies: [r, r] })
    let result = mergeDiscussionEntriesWithNewEntries([a], [rr])

    expect(result).toEqual([ a, rr ])
  })

  it('mergeDiscussionEntriesWithNewEntries for nested reply', () => {
    let r = template.discussionReply({ id: '1' })
    let rr = template.discussionReply({ id: '2' })
    let rrr = template.discussionReply({ id: '3', parent_id: '2' })
    let a = template.discussionReply({ id: '11', replies: [r, rr] })
    let expected = template.discussionReply({ id: '2', replies: [rrr] })
    let expectedA = template.discussionReply({ id: '11', replies: [r, expected] })
    let result = mergeDiscussionEntriesWithNewEntries([a], [rrr])

    expect(result).toEqual([
      expectedA,
    ])
  })
})

describe('discussionData', () => {
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
  })
  describe('refreshDiscussionEntries', () => {
    it('handles resolved with existing disucssion', () => {
      let participantA = template.userDisplay({ id: '1', display_name: 'A' })
      let participantB = template.userDisplay({ id: '2', display_name: 'B' })
      let view = template.discussionView({ participants: [participantA, participantB] })
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

      expect(discussions({ [stateDiscussion.id]: { data: stateDiscussion } }, resolved)).toEqual({
        '1': {
          data: expected,
          pending: 0,
          error: null,
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
          pending: 0,
          error: null,
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
        payload: { result: { data: discussion } },
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
    it('handles resolved empty state', () => {
      const initialState = {}
      const resolved = {
        type: createEntry.toString(),
        payload: {
          discussionID: '1',
        },
      }
      expect(
        discussions(initialState, resolved)
      ).toEqual({
        '1': {
          replies: {
            new: {
              pending: 0,
              error: null,
            },
          },
        },
      })
    })

    it('handles resolved non empty state', () => {
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
              template.discussionReply({ id: '1' }),
            ],
          }),
          replies: {
            new: {
              pending: 2,
              error: 'WAT',
            },
          },
        },
      }
      const resolved = {
        type: createEntry.toString(),
        payload: {
          discussionID: '2',
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
        },
      })
    })

    it('handles pending empty state', () => {
      const initialState = {}
      const pending = {
        type: createEntry.toString(),
        pending: true,
        payload: {
          discussionID: '2',
        },
      }
      expect(
        discussions(initialState, pending)
      ).toEqual({
        '2': {
          replies: {
            new: {
              pending: 1,
              error: null,
            },
          },
        },
      })
    })

    it('handles pending non empty state', () => {
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
      expect(
        discussions(initialState, pending)
      ).toEqual({
        ...initialState,
        '2': {
          data: template.discussion({ id: '2' }),
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
    })

    it('handles rejected empty state', () => {
      const initialState = {}
      const rejected = {
        type: createEntry.toString(),
        error: true,
        payload: {
          discussionID: '2',
          error: template.error('User not authorized'),
        },
      }
      expect(
        discussions(initialState, rejected)
      ).toEqual({
        '2': {
          replies: {
            new: {
              pending: 0,
              error: 'User not authorized',
            },
          },
        },
      })
    })

    it('handles rejected non empty state', () => {
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
            new: {
              pending: 0,
              error: 'User not authorized',
            },
          },
        },
      })
    })
  })
})
