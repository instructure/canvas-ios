//
// Copyright (C) 2017-present Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import { NativeModules, Alert, ActionSheetIOS } from 'react-native'
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

  it('uses default html when body is null', () => {
    props.page = template.pageModel({ body: null })
    const screen = shallow(<PageDetails {...props} />)
    const webView = screen.find('CanvasWebView')
    const source = webView.prop('source')
    expect(source.html).toEqual('')
  })

  it('does not mark page as viewed when a teacher', () => {
    app.setCurrentApp('teacher')
    const spy = jest.fn()
    NativeModules.ModuleItemsProgress.viewedPage = spy
    props.courseID = '33'
    props.url = 'view-this'
    shallow(<PageDetails {...props} />)
    expect(spy).not.toHaveBeenCalled()
  })

  it('marks page as viewed', () => {
    app.setCurrentApp('student')
    const spy = jest.fn()
    NativeModules.ModuleItemsProgress.viewedPage = spy
    props.courseID = '33'
    props.url = 'view-this'
    shallow(<PageDetails {...props} />)
    expect(spy).toHaveBeenCalledWith('33', 'view-this')
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

  it('renders while loading', () => {
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

  it('sets specific error message for 404', () => {
    const tree = shallow(<PageDetails {...props} />)
    const loadError = {
      response: { status: 404 },
    }
    tree.setProps({ loadError })
    expect(alertError).toHaveBeenCalledWith('Oops, we couldn’t find that page.', 'Page Not Found')
  })

  it('routes to page edit', async () => {
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
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
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
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
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
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
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

  it('doesnt show delete for a student', async () => {
    app.setCurrentApp('student')
    ActionSheetIOS.showActionSheetWithOptions = jest.fn()
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())

    props.page = template.pageModel({ url: 'page-1', isFrontPage: false, editingRoles: ['students', 'teacher'] })
    const tree = shallow(<PageDetails {...props} />)
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'pages.details.editButton')
      .action()
    expect(ActionSheetIOS.showActionSheetWithOptions.mock.calls[0][0].options).toEqual(['Edit', 'Cancel'])
  })

  it('cant edit while loading', () => {
    props.course = null
    props.page = null
    props.isLoading = true
    const tree = shallow(<PageDetails {...props} />)
    let screen = tree.find('Screen')
    expect(screen.prop('rightBarButtons')).toEqual(false)
  })

  it('cant edit without a page', () => {
    props.course = null
    props.page = null
    props.isLoading = false
    const tree = shallow(<PageDetails {...props} />)
    let screen = tree.find('Screen')
    expect(screen.prop('rightBarButtons')).toEqual(false)
  })

  it('can edit if the teacher app', () => {
    app.setCurrentApp('teacher')
    const tree = shallow(<PageDetails {...props} />)
    let screen = tree.find('Screen')
    expect(screen.prop('rightBarButtons')[0].testID).toEqual('pages.details.editButton')
  })

  it('cant edit if the student app and page does not support it', () => {
    app.setCurrentApp('student')
    const tree = shallow(<PageDetails {...props} />)
    let screen = tree.find('Screen')
    expect(screen.prop('rightBarButtons')).toEqual(false)
  })

  it('can edit if the page supports student editing in the student app', () => {
    app.setCurrentApp('student')
    props.page.editingRoles = ['students', 'teacher']
    const tree = shallow(<PageDetails {...props} />)
    let screen = tree.find('Screen')
    expect(screen.prop('rightBarButtons')[0].testID).toEqual('pages.details.editButton')
  })

  it('can edit if the page supports public editing in the student app', () => {
    app.setCurrentApp('student')
    props.page.editingRoles = ['public', 'students', 'teacher']
    const tree = shallow(<PageDetails {...props} />)
    let screen = tree.find('Screen')
    expect(screen.prop('rightBarButtons')[0].testID).toEqual('pages.details.editButton')
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

  it('refreshes when webview refreshes', () => {
    props.refresh = jest.fn()
    const screen = shallow(<PageDetails {...props} />)
    expect(props.refresh).not.toHaveBeenCalled()
    const webView = screen.find('CanvasWebView')
    webView.simulate('Refresh')
    expect(props.refresh).toHaveBeenCalled()
  })

  it('calls stops refreshing webview if not loading', () => {
    const stopRefreshing = jest.fn()
    const screen = shallow(<PageDetails {...props} />)
    screen.find('CanvasWebView').getElement().ref({ stopRefreshing })
    screen.setProps({ isLoading: false })
    expect(stopRefreshing).toHaveBeenCalled()
  })
})
