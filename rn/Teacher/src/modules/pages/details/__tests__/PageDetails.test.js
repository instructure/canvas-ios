/* @flow */

import React from 'react'
import { Alert } from 'react-native'
import renderer from 'react-test-renderer'
import { PageDetails, mapStateToProps, type Props } from '../PageDetails'
import { defaultErrorTitle } from '../../../../redux/middleware/error-handler'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../__templates__/page'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/error'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('PageDetails', () => {
  let props: Props
  beforeEach(() => {
    props = {
      page: template.page(),
      courseID: '1',
      getPage: jest.fn(() => Promise.resolve({ data: template.page() })),
      refreshedPage: jest.fn(),
      navigator: template.navigator(),
      courseName: 'Course 1',
      url: 'page-1',
    }
  })

  it('renders', () => {
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders without page', () => {
    props.page = null
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('refreshes page on mount', () => {
    props.page = null
    props.url = 'page-1'
    const spy = jest.fn(() => Promise.resolve({ data: template.page() }))
    props.getPage = spy
    const view = render(props)
    view.getInstance().componentWillMount()
    expect(spy).toHaveBeenCalledWith(props.courseID, 'page-1')
  })

  it('dispatches refreshedPage action on refresh', async () => {
    const spy = jest.fn()
    props.refreshedPage = spy
    const page = template.page()
    props.getPage = jest.fn(() => Promise.resolve({ data: page }))
    const view = render(props)
    await view.getInstance().componentWillMount()
    expect(spy).toHaveBeenCalledWith(page, props.courseID)
  })

  it('alerts when refresh fails', async () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    props.getPage = jest.fn(() => Promise.reject(template.error('fail')))
    const view = render(props)
    await view.getInstance().componentWillMount()
    expect(spy).toHaveBeenCalledWith(defaultErrorTitle(), 'fail')
  })

  function render (props: Props, options: any = {}): any {
    return renderer.create(<PageDetails {...props} />, options)
  }
})

describe('mapStateToProps', () => {
  it('maps course and page to props', () => {
    const page = template.page({ url: 'page-1' })
    const state = template.appState({
      entities: {
        pages: {
          'page-1': {
            data: page,
          },
        },
      },
    })
    expect(mapStateToProps(state, { courseID: '1', url: 'page-1' })).toEqual({
      page,
      courseName: '',
    })
  })

  it('maps course name to props', () => {
    const state = template.appState({
      entities: {
        courses: {
          '1': {
            course: template.course({ name: 'Course FTW' }),
          },
        },
      },
    })
    expect(mapStateToProps(state, { courseID: '1', url: 'page-1' })).toEqual({
      page: undefined,
      courseName: 'Course FTW',
    })
  })
})
