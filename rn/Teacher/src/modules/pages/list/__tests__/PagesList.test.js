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

import { shallow } from 'enzyme'
import React from 'react'
import { alertError } from '../../../../redux/middleware/error-handler'
import { httpCache } from '../../../../canvas-api/model-api'
import * as template from '../../../../__templates__'
import app from '../../../app'
import ConnectedPagesList, { PagesList } from '../PagesList'

jest.mock('../../../../redux/middleware/error-handler', () => {
  return { alertError: jest.fn() }
})
jest.useFakeTimers()

const diveList = (list: any) =>
  shallow(
    <list>
      {list.prop('data').map((item, index) =>
        <item key={list.prop('keyExtractor')(item)}>
          {list.prop('renderItem')({ item, index })}
        </item>
      )}
    </list>
  )

describe('PagesList', () => {
  let props
  beforeEach(() => {
    jest.clearAllMocks()
    httpCache.clear()
    props = {
      courseID: '1',
      navigator: template.navigator(),
      courseColor: 'green',
      course: template.courseModel({ id: '1' }),
      pages: [template.pageModel()],
      isLoading: false,
      loadError: null,
      refresh: jest.fn(),
    }
  })

  it('gets courseColor, course, and pages from the model api', () => {
    const courseColor = 'green'
    const course = [ template.courseModel() ]
    const pages = [ template.pageModel() ]
    httpCache.handle('GET', 'users/self/colors', { custom_colors: { course_1: courseColor } })
    httpCache.handle('GET', 'courses/1', course)
    httpCache.handle('GET', 'courses/1/pages', { list: pages })
    const tree = shallow(<ConnectedPagesList courseID='1' />)
    expect(tree.find(PagesList).props()).toMatchObject({
      courseColor,
      course,
      pages,
    })
  })

  it('renders empty', () => {
    props.pages = []
    const tree = shallow(<PagesList {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders loading', () => {
    props.course = null
    props.pages = []
    props.isLoading = true
    const tree = shallow(<PagesList {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders front page row', () => {
    props.pages = [template.pageModel({ isFrontPage: true, title: 'Page 1' })]
    const tree = shallow(<PagesList {...props} />)
    const row = diveList(tree.find('FlatList')).find('FeatureRow').first()
    expect(row.prop('title')).toBe('Front Page')
    expect(row.prop('subtitle')).toBe('Page 1')
  })

  it('sorts the pages list', () => {
    const tree = shallow(<PagesList {...props} />)
    const pages = [
      template.pageModel({ title: 'Page B' }),
      template.pageModel({ isFrontPage: true, title: 'Page 1' }),
      template.pageModel({ title: 'Page A' }),
    ]
    tree.setProps({ pages })
    const sorted = tree.find('FlatList').prop('data')
    expect(sorted).toEqual([
      template.pageModel({ isFrontPage: true, title: 'Page 1' }),
      template.pageModel({ title: 'Page A' }),
      template.pageModel({ title: 'Page B' }),
    ])
    tree.setProps({ pages }) // not changed
    expect(tree.find('FlatList').prop('data')).toBe(sorted)
  })

  it('shows access icon for teachers', () => {
    app.setCurrentApp('teacher')
    const tree = shallow(<PagesList {...props} />)
    const row = diveList(tree.find('FlatList')).find('Row').first()
    expect(row.prop('renderImage')()).toMatchSnapshot()
  })

  it('alerts on new loadError', () => {
    const tree = shallow(<PagesList {...props} />)
    tree.setProps({ loadError: null })
    expect(alertError).not.toHaveBeenCalled()
    const loadError = new Error()
    tree.setProps({ loadError })
    expect(alertError).toHaveBeenCalledWith(loadError)
  })

  it('navigates to page details', () => {
    props.navigator = template.navigator({ show: jest.fn() })
    props.pages = [template.pageModel({ url: 'abc' })]
    const tree = shallow(<PagesList {...props} />)
    diveList(tree.find('FlatList')).find('Row').first()
      .simulate('Press', 'abc')
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/1/pages/abc',
      { modal: false }
    )
  })

  it('navigates to new page', () => {
    props.navigator = template.navigator({ show: jest.fn() })
    const tree = shallow(<PagesList {...props} />)
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'pages.list.add.button')
      .action()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/1/pages/new',
      { modal: true, modalPresentationStyle: 'formsheet' }
    )
  })

  it('shows add button if permitted', () => {
    app.setCurrentApp('teacher')
    const tree = shallow(<PagesList {...props} />)
    expect(
      tree.prop('rightBarButtons').find(({ testID }) => testID === 'pages.list.add.button')
    ).toBeTruthy()
  })

  it('hides add button if not permitted', () => {
    app.setCurrentApp('student')
    const tree = shallow(<PagesList {...props} />)
    expect(tree.prop('rightBarButtons')).toBeFalsy()
  })

  it('shows front page', () => {
    props.navigator = template.navigator({
      traitCollection: (callback) => {
        callback({
          screen: {
            horizontal: 'regular',
          },
          window: {
            horizontal: 'regular',
          },
        })
      },
    })
    props.pages = [template.pageModel({ url: 'front-page', isFrontPage: true })]
    shallow(<PagesList {...props} />)
    expect(props.navigator.show).toHaveBeenLastCalledWith(
      '/courses/1/pages/front-page',
      { modal: false },
    )
  })

  it('does not show front page on deep link modal', () => {
    props.navigator = template.navigator({
      traitCollection: (callback) => {
        callback({
          screen: {
            horizontal: 'regular',
          },
          window: {
            horizontal: 'regular',
          },
        })
      },
      isModal: true,
    })
    props.pages = [template.pageModel({ url: 'front-page', isFrontPage: true })]
    shallow(<PagesList {...props} />)
    expect(props.navigator.show).not.toHaveBeenCalled()
  })

  it('shows placeholder if no front page', () => {
    props.navigator = template.navigator({
      traitCollection: (callback) => {
        callback({
          screen: {
            horizontal: 'regular',
          },
          window: {
            horizontal: 'regular',
          },
        })
      },
    })
    props.pages = [template.pageModel({ isFrontPage: false })]
    const course = props.course = template.courseModel({ id: '1' })
    shallow(<PagesList {...props} />)
    expect(props.navigator.show).toHaveBeenLastCalledWith(
      '/courses/1/placeholder',
      {},
      { courseColor: 'green', course: course.raw },
    )
  })

  it('shows front page or placeholder when switching to split screen', () => {
    let traits = {
      screen: { horizontal: 'compact' },
      window: { horizontal: 'compact' },
    }
    props.navigator = template.navigator({
      traitCollection: (callback) => { callback(traits) },
    })
    props.pages = [template.pageModel({ isFrontPage: false })]
    const course = props.course = template.courseModel({ id: '1' })
    const tree = shallow(<PagesList {...props} />)
    traits = {
      screen: { horizontal: 'regular' },
      window: { horizontal: 'regular' },
    }
    tree.find('Screen').simulate('TraitCollectionChange')
    expect(props.navigator.show).toHaveBeenLastCalledWith(
      '/courses/1/placeholder',
      {},
      { courseColor: 'green', course: course.raw },
    )
  })
})
