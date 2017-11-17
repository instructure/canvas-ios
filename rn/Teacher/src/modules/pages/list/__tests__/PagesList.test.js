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

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import { PagesList, mapStateToProps, type Props } from '../PagesList'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../__templates__/page'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('PagesList', () => {
  let props: Props
  beforeEach(() => {
    props = {
      pages: [template.page()],
      courseID: '1',
      getPages: jest.fn(() => Promise.resolve({ data: [template.page()] })),
      refreshedPages: jest.fn(),
      navigator: template.navigator(),
    }
  })

  it('renders', () => {
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders empty', () => {
    props.pages = []
    expect(render(props)).toMatchSnapshot()
  })

  it('refreshes on mount', () => {
    const spy = jest.fn(() => Promise.resolve({ data: [template.page()] }))
    props.getPages = spy
    const view = render(props)
    view.getInstance().componentWillMount()
    expect(spy).toHaveBeenCalledWith(props.courseID)
  })

  it('dispatches refreshedPages action on refresh', async () => {
    const pages = [template.page()]
    props.getPages = jest.fn(() => Promise.resolve({ data: pages }))
    const spy = jest.fn()
    props.refreshedPages = spy
    const view = render(props)
    const list: any = explore(view.toJSON()).selectByType('RCTScrollView')
    await list.props.onRefresh()
    expect(spy).toHaveBeenCalledWith(pages, props.courseID)
  })

  it('renders front page pill', () => {
    props.pages = [template.page({ front_page: true })]
    const pill = explore(render(props).toJSON()).selectByID('pages.list.front-page.pill')
    expect(pill).not.toBeNull()
  })

  it('navigates to page details', () => {
    const spy = jest.fn()
    props.navigator = template.navigator({
      show: spy,
    })
    props.pages = [template.page({ url: 'abc' })]
    props.courseID = '1'
    const view = render(props)
    const row: any = explore(view.toJSON()).selectByID('pages.list.page.row-0')
    row.props.onPress()
    expect(spy).toHaveBeenCalledWith('/courses/1/pages/abc', { modal: false })
  })

  function render (props: Props, options: any = {}): any {
    return renderer.create(<PagesList {...props} />, options)
  }
})

describe('mapStateToProps', () => {
  it('maps state to props', () => {
    const one = template.page({ url: 'page-1', title: 'A' })
    const two = template.page({ url: 'page-2', title: 'B' })
    const three = template.page({ url: 'page-3', title: 'C' })
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            color: '#fff',
            course: {
              name: 'Course 1',
            },
            pages: {
              pending: 0,
              refs: ['page-1', 'page-3'],
            },
          },
        },
        pages: {
          'page-1': { data: one },
          'page-2': { data: two },
          'page-3': { data: three },
        },
      },
    })
    expect(mapStateToProps(state, { courseID: '1' })).toEqual({
      pages: [one, three],
      courseName: 'Course 1',
      courseColor: '#fff',
    })
  })

  it('maps empty state to props', () => {
    const state = template.appState()
    expect(mapStateToProps(state, { courseID: '1' })).toEqual({
      pages: [],
      courseName: '',
      courseColor: null,
    })
  })

  it('sorts pages alphabetically by title', () => {
    const A = template.page({ url: 'A', title: 'A' })
    const b = template.page({ url: 'b', title: 'b' })
    const C = template.page({ url: 'C', title: 'C' })
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            color: '#fff',
            course: {
              name: 'Course 1',
            },
            pages: {
              pending: 0,
              refs: ['A', 'b', 'C'],
            },
          },
        },
        pages: {
          'A': { data: A },
          'b': { data: b },
          'C': { data: C },
        },
      },
    })
    expect(mapStateToProps(state, { courseID: '1' })).toMatchObject({
      pages: [A, b, C],
    })
  })
})
