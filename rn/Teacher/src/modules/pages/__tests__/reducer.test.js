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

import { refs, entities, frontPage } from '../reducer'
import { default as ListActions } from '../list/actions'
import { default as DetailsActions } from '../details/actions'

const { refreshedPages } = ListActions
const { refreshedPage, deletedPage } = DetailsActions

const template = {
  ...require('../../../__templates__/page'),
}

describe('refs', () => {
  describe('refreshedPages', () => {
    const pages = [
      template.page({ page_id: 'page-1' }),
      template.page({ page_id: 'page-2' }),
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
    const page = template.page({ page_id: 'page-1' })
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

  describe('deletedPage', () => {
    const page = template.page({ page_id: '1' })
    const action = deletedPage(page, '1')

    it('removes page ref', () => {
      const initialState = {
        pending: 0,
        refs: ['1', '2'],
      }
      expect(refs(initialState, action)).toEqual({
        pending: 0,
        refs: ['2'],
      })
    })
  })
})

describe('entities', () => {
  describe('refreshedPages', () => {
    const one = template.page({ page_id: 'page-1', body: undefined })
    const two = template.page({ page_id: 'page-2', body: undefined })
    const action = refreshedPages([one, two], '1')

    it('adds pages by page_id', () => {
      expect(entities({}, action)).toEqual({
        'page-1': { data: one },
        'page-2': { data: two },
      })
    })

    it('does not override page body', () => {
      const initialState = {
        [one.page_id]: {
          data: { ...one, body: 'keep me' },
        },
      }
      expect(entities(initialState, action)).toMatchObject({
        [one.page_id]: { data: { ...one, body: 'keep me' } },
      })
    })
  })

  describe('refreshedPage', () => {
    const page = template.page({ page_id: 'page-1' })
    const action = refreshedPage(page, '1')

    it('adds page', () => {
      expect(entities({}, action)).toEqual({
        'page-1': { data: page },
      })
    })
  })

  describe('deletedPage', () => {
    const page = template.page({ page_id: '1' })
    const action = deletedPage(page, '1')

    it('removes page', () => {
      const initialState = {
        [page.page_id]: {
          data: page,
        },
      }
      expect(entities(initialState, action)).toEqual({})
    })
  })
})

describe('frontPage', () => {
  it('returns state if the new page is not the front page', () => {
    const state = {}
    const page = template.page({ front_page: false })
    const action = refreshedPage(page, '1')
    expect(frontPage(state, action)).toEqual(state)
  })

  it('returns state if there is not an old front page', () => {
    const state = {
      courses: {
        '1': {
          pages: {
            refs: [],
          },
        },
      },
    }
    const page = template.page({ front_page: true })
    const action = refreshedPage(page, '1')
    expect(frontPage(state, action)).toEqual(state)
  })

  it('returns state if the front page didnt change', () => {
    const page = template.page({ page_id: '1', front_page: true })
    const state = {
      courses: {
        '1': {
          pages: {
            refs: ['1'],
          },
        },
      },
      pages: {
        '1': {
          data: page,
        },
      },
    }
    const action = refreshedPage(page, '1')
    expect(frontPage(state, action)).toEqual(state)
  })

  it('updates old front page', () => {
    const oldFrontPage = template.page({ page_id: '1', front_page: true })
    const newFrontPage = template.page({ page_id: '2', front_page: false })
    const state = {
      courses: {
        '1': {
          pages: {
            refs: [oldFrontPage.page_id, newFrontPage.page_id],
          },
        },
      },
      pages: {
        [oldFrontPage.page_id]: {
          data: oldFrontPage,
        },
        [newFrontPage.page_id]: {
          data: newFrontPage,
        },
      },
    }
    const action = refreshedPage({ ...newFrontPage, front_page: true }, '1')
    expect(frontPage(state, action)).toEqual({
      ...state,
      pages: {
        ...state.pages,
        [oldFrontPage.page_id]: {
          data: { ...oldFrontPage, front_page: false },
        },
      },
    })
  })
})
