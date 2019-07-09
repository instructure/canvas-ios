//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* @flow */

import { refs } from '../reducer'
import { default as ListActions } from '../list/actions'
import { default as EditActions } from '../../discussions/edit/actions'

const { refreshAnnouncements } = ListActions
const { createDiscussion, deleteDiscussion } = EditActions

const template = {
  ...require('../../../__templates__/discussion'),
  ...require('../../../__templates__/error'),
}

describe('refs', () => {
  describe('refreshAnnouncements', () => {
    const data = [
      template.discussion({ id: '1' }),
      template.discussion({ id: '2' }),
    ]
    const pending = {
      type: refreshAnnouncements.toString(),
      pending: true,
    }

    it('handles pending', () => {
      expect(
        refs(undefined, pending)
      ).toEqual({
        refs: [],
        pending: 1,
      })
    })

    it('handles resolved', () => {
      const initialState = refs(undefined, pending)
      const resolved = {
        type: refreshAnnouncements.toString(),
        payload: { result: { data } },
      }
      expect(
        refs(initialState, resolved)
      ).toEqual({
        pending: 0,
        refs: ['1', '2'],
      })
    })
  })

  describe('createDiscussion', () => {
    const pending = {
      type: createDiscussion.toString(),
      pending: true,
    }

    it('adds ref if discussion is an announcement', () => {
      const announcement = template.discussion({
        id: '23',
        is_announcement: true,
      })
      const initialState = refs(undefined, pending)
      const resolved = {
        type: createDiscussion.toString(),
        payload: { result: { data: announcement } },
      }
      expect(
        refs(initialState, resolved)
      ).toEqual({
        pending: 0,
        refs: ['23'],
      })
    })
  })

  describe('deleteDiscussion', () => {
    it('removes ref', () => {
      const initialState = {
        pending: 0,
        refs: ['3', '33'],
      }
      const resolved = {
        type: deleteDiscussion.toString(),
        payload: {
          discussionID: '3',
        },
      }
      expect(
        refs(initialState, resolved)
      ).toEqual({
        pending: 0,
        refs: ['33'],
      })
    })

    it('should not explode when refs are not there', () => {
      const initialState = {
        pending: 0,
      }
      const resolved = {
        type: deleteDiscussion.toString(),
        payload: {
          discussionID: '3',
        },
      }
      expect(
        refs(initialState, resolved)
      ).toEqual({
        pending: 0,
        refs: [],
      })
    })
  })
})
