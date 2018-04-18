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
import { Alert, ActionSheetIOS } from 'react-native'
import URL from 'url-parse'
import { alertError } from '../../../../redux/middleware/error-handler'
import { API, httpCache } from '../../../../canvas-api/model-api'
import * as template from '../../../../__templates__'
import app from '../../../app'
import ConnectedPageDetails, { PageDetails } from '../PageDetails'

jest.mock('../../../../redux/middleware/error-handler', () => {
  return { alertError: jest.fn() }
})
jest.useFakeTimers()

describe('PageDetails', () => {
  let props
  beforeEach(() => {
    httpCache.clear()
    app.setCurrentApp('teacher')
    props = {
      location: new URL('/pages/page-1#jumpto'),
      courseID: '1',
      url: 'page-1',
      navigator: template.navigator(),
      page: template.pageModel({ url: 'page-1' }),
      course: template.courseModel({ id: '1', name: 'Course 1' }),
      courseColor: '#fff',
      api: new API({ policy: 'cache-only' }),
      isLoading: false,
      loadError: null,
      refresh: jest.fn(),
    }
  })

  it('gets courseColor, course, and page from the model api', () => {
    const courseColor = 'green'
    const course = [ template.courseModel() ]
    const page = template.pageModel({ url: 'test' })
    httpCache.handle('GET', 'users/self/colors', { custom_colors: { course_1: courseColor } })
    httpCache.handle('GET', 'courses/1', course)
    httpCache.handle('GET', 'courses/1/pages/test', page)
    const tree = shallow(<ConnectedPageDetails courseID='1' url='test' />)
    expect(tree.find(PageDetails).props()).toMatchObject({
      courseColor,
      course,
      page,
    })
  })

  it('gets front page if the url matches', () => {
    const page = template.pageModel({ url: 'somewhere' })
    httpCache.handle('GET', 'users/self/colors', { custom_colors: { course_1: 'green' } })
    httpCache.handle('GET', 'courses/1', template.courseModel())
    httpCache.handle('GET', 'courses/1/front_page', page)
    const tree = shallow(<ConnectedPageDetails courseID='1' url='front_page' />)
    expect(tree.find(PageDetails).props()).toMatchObject({
      page,
    })
  })

  it('renders', () => {
    const tree = shallow(<PageDetails {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders while loading', async () => {
    props.course = null
    props.page = null
    props.isLoading = true
    const tree = shallow(<PageDetails {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('alerts on new loadError', () => {
    const tree = shallow(<PageDetails {...props} />)
    tree.setProps({ loadError: null })
    expect(alertError).not.toHaveBeenCalled()
    const loadError = new Error()
    tree.setProps({ loadError })
    expect(alertError).toHaveBeenCalledWith(loadError)
  })

  it('routes to page edit', async () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(0))
    props.navigator = template.navigator({ show: jest.fn() })
    props.courseID = '1'
    props.url = 'page-1'
    const tree = shallow(<PageDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'pages.details.editButton')
      .action()
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/1/pages/page-1/edit',
      { modal: true, modalPresentationStyle: 'formsheet' },
      { onChange: expect.any(Function) }
    )
  })

  it('deletes page', async () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    // $FlowFixMe
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())

    props.api.deletePage = jest.fn()
    props.page = template.pageModel({ url: 'page-1', isFrontPage: false })
    const tree = shallow(<PageDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'pages.details.editButton')
      .action()
    expect(props.api.deletePage).toHaveBeenCalledWith('courses', props.courseID, 'page-1')
  })

  it('cant delete front page', async () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    // $FlowFixMe
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())

    props.api.deletePage = jest.fn()
    props.page = template.pageModel({ url: 'page-1', isFrontPage: true })
    const tree = shallow(<PageDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'pages.details.editButton')
      .action()
    expect(props.api.deletePage).not.toHaveBeenCalled()
  })

  it('alerts error deleting page', async () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    // $FlowFixMe
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())

    const error = new Error()
    const rejection = Promise.reject(error)
    props.api.deletePage = jest.fn(() => rejection)
    props.page = template.pageModel({ url: 'page-1', isFrontPage: false })
    const tree = shallow(<PageDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'pages.details.editButton')
      .action()
    expect(props.api.deletePage).toHaveBeenCalledWith('courses', props.courseID, 'page-1')
    await rejection.catch(() => {})
    expect(alertError).toHaveBeenCalledWith(error)
  })

  it('shows edit button if permitted', () => {
    app.setCurrentApp('teacher')
    const tree = shallow(<PageDetails {...props} />)
    const button = tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'pages.details.editButton')
    expect(button).toBeDefined()
  })

  it('hides edit button if not permitted', () => {
    app.setCurrentApp('student')
    const tree = shallow(<PageDetails {...props} />)
    expect(tree.find('Screen').prop('rightBarButtons')).toBeFalsy()
  })

  it('bails out without error when page is null', () => {
    props.page = null
    const tree = shallow(<PageDetails {...props} />)
    expect(tree.instance().edit).not.toThrow()
    expect(tree.instance().showEditActionSheet).not.toThrow()
    expect(tree.instance()._editActionSheetSelected).not.toThrow()
    expect(tree.instance().delete).not.toThrow()
  })

  it('replaces navigation when edited page url changes', () => {
    props.navigator = template.navigator({
      show: jest.fn(),
      replace: jest.fn(),
    })
    const tree = shallow(<PageDetails {...props} />)
    tree.instance().edit()
    const { onChange } = props.navigator.show.mock.calls[0][2]
    onChange(props.page)
    expect(props.navigator.replace).not.toHaveBeenCalled()
    onChange(template.pageModel({ url: 'updated-3' }))
    expect(props.navigator.replace).toHaveBeenCalledWith(
      '/courses/1/pages/updated-3'
    )
  })
})
