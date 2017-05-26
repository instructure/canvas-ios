/* @flow */

import { refs, discussions } from '../reducer'
import { default as ListActions } from '../list/actions'

const { refreshDiscussions } = ListActions

const template = {
  ...require('../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../api/canvas-api/__templates__/error'),
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
})
