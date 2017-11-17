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

// @flow

import { refs, entities } from '../reducer'
import { default as ListActions } from '../list/actions'
import { default as DetailsActions } from '../details/actions'

const { refreshedPages } = ListActions
const { refreshedPage } = DetailsActions

const template = {
  ...require('../../../__templates__/page'),
}

describe('refs', () => {
  describe('refreshedPages', () => {
    const pages = [
      template.page({ url: 'page-1' }),
      template.page({ url: 'page-2' }),
    ]
    const action = refreshedPages(pages, '1')

    it('maps page urls to refs', () => {
      expect(refs({}, action)).toEqual({
        pending: 0,
        refs: ['page-1', 'page-2'],
      })
    })
  })

  describe('refreshedPage', () => {
    const page = template.page({ url: 'page-1' })
    const action = refreshedPage(page, '1')

    it('adds url to refs if it doesnt exist', () => {
      expect(refs({}, action)).toEqual({
        pending: 0,
        refs: ['page-1'],
      })
    })

    it('keeps refs unique', () => {
      const initialState = {
        pending: 0,
        refs: ['page-1'],
      }
      expect(refs(initialState, action)).toEqual({
        pending: 0,
        refs: ['page-1'],
      })
    })
  })
})

describe('entities', () => {
  describe('refreshedPages', () => {
    const one = template.page({ url: 'page-1' })
    const two = template.page({ url: 'page-2' })
    const action = refreshedPages([one, two], '1')

    it('organizes pages by url', () => {
      expect(entities({}, action)).toEqual({
        'page-1': { data: one },
        'page-2': { data: two },
      })
    })
  })

  describe('refreshedPage', () => {
    const page = template.page({ url: 'page-1' })
    const action = refreshedPage(page, '1')

    it('adds page', () => {
      expect(entities({}, action)).toEqual({
        'page-1': { data: page },
      })
    })
  })
})
