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
