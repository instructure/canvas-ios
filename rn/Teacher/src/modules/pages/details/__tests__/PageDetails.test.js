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
import { Alert, ActionSheetIOS } from 'react-native'
import renderer from 'react-test-renderer'
import { PageDetails, mapStateToProps, type Props } from '../PageDetails'
import { setSession } from '../../../../canvas-api'
import { defaultErrorTitle } from '../../../../redux/middleware/error-handler'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing/Screen')

const template = {
  ...require('../../../../__templates__/page'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/error'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/session'),
}

describe('PageDetails', () => {
  let props: Props
  beforeAll(() => setSession(template.session()))
  beforeEach(() => {
    props = {
      pages: {},
      courseID: '1',
      getPage: jest.fn(() => Promise.resolve({ data: template.page() })),
      deletePage: jest.fn(() => Promise.resolve({ data: template.page() })),
      refreshedPage: jest.fn(),
      deletedPage: jest.fn(),
      navigator: template.navigator(),
      courseName: 'Course 1',
      url: 'page-1',
    }
  })

  it('renders', async () => {
    expect((await render(props)).toJSON()).toMatchSnapshot()
  })

  it('renders without page', async () => {
    expect((await render(props, null)).toJSON()).toMatchSnapshot()
  })

  it('refreshes page on mount', async () => {
    props.url = 'page-1'
    const spy = jest.fn(() => Promise.resolve({ data: template.page() }))
    props.getPage = spy
    const view = await render(props, null)
    view.getInstance().componentWillMount()
    expect(spy).toHaveBeenCalledWith(props.courseID, 'page-1')
  })

  it('dispatches refreshedPage action on refresh', async () => {
    const spy = jest.fn()
    props.refreshedPage = spy
    const page = template.page()
    props.getPage = jest.fn(() => Promise.resolve({ data: page }))
    const view = await render(props)
    await view.getInstance().componentWillMount()
    expect(spy).toHaveBeenCalledWith(page, props.courseID)
  })

  it('alerts when refresh fails', async () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    props.getPage = jest.fn(() => Promise.reject(template.error('fail')))
    const view = await render(props, null)
    await view.getInstance().componentWillMount()
    expect(spy).toHaveBeenCalledWith(defaultErrorTitle(), 'fail')
  })

  it('routes to page edit', async () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(0))
    const spy = jest.fn()
    props.navigator = template.navigator({ show: spy })
    props.courseID = '1'
    props.url = 'page-1'
    const view = await render(props)
    const edit: any = explore(view.toJSON()).selectRightBarButton('pages.details.editButton')
    edit.action()
    expect(spy).toHaveBeenCalledWith('/courses/1/pages/page-1/edit', {
      modal: true,
      modalPresentationStyle: 'formsheet',
    })
  })

  it('deletes page', async () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    // $FlowFixMe
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())

    const spy = jest.fn()
    props.deletePage = spy
    const page = template.page({ url: 'page-1', front_page: false })
    const view = await render(props, page)
    const edit: any = explore(view.toJSON()).selectRightBarButton('pages.details.editButton')
    edit.action()
    expect(spy).toHaveBeenCalledWith(props.courseID, 'page-1')
  })

  it('cant delete front page', async () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    // $FlowFixMe
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())

    const spy = jest.fn()
    props.deletePage = spy
    const page = template.page({ url: 'page-1', front_page: true })
    const view = await render(props, page)
    const edit: any = explore(view.toJSON()).selectRightBarButton('pages.details.editButton')
    edit.action()
    expect(spy).not.toHaveBeenCalled()
  })

  it('only shows done button if presented modally', async () => {
    const view = await render(props)
    expect(
      explore(view.toJSON()).selectLeftBarButton('page.details.dismiss.button')
    ).toBeNull()

    props.navigator = template.navigator({ isModal: true })
    const view2 = await render(props)
    expect(
      explore(view2.toJSON()).selectLeftBarButton('page.details.dismiss.button')
    ).not.toBeNull()
  })

  it('dismisses when tap done', async () => {
    props.navigator = template.navigator({ isModal: true })
    const spy = jest.fn()
    props.navigator.dismiss = spy
    const view = await render(props)
    const doneButton: any = explore(view.toJSON()).selectLeftBarButton('page.details.dismiss.button')
    doneButton.action()
    expect(spy).toHaveBeenCalled()
  })

  async function render (props: Props, page: ?Page = template.page(), options: any = {}): any {
    if (page) {
      props.getPage = jest.fn(() => Promise.resolve({ data: page }))
    }
    const view = renderer.create(<PageDetails {...props} />, options)
    await view.getInstance().componentWillMount()
    if (page) {
      setProps(view, {
        pages: { [page.page_id]: page },
      })
    }
    return view
  }
})

describe('mapStateToProps', () => {
  it('maps course and page to props', () => {
    const page = template.page({ page_id: '1', url: 'page-1' })
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course: template.course({ name: '' }),
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
      },
    })
    expect(mapStateToProps(state, { courseID: '1', url: 'page-1' })).toEqual({
      pages: { '1': page },
      courseName: '',
    })
  })

  it('maps course name to props', () => {
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            pages: { refs: [] },
            course: template.course({ name: 'Course FTW' }),
          },
        },
      },
    })
    expect(mapStateToProps(state, { courseID: '1', url: 'page-1' })).toEqual({
      pages: {},
      courseName: 'Course FTW',
    })
  })
})
