/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import { PageDetails, type Props } from '../PageDetails'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../__templates__/page'),
  ...require('../../../../__templates__/helm'),
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

  function render (props: Props, options: any = {}): any {
    return renderer.create(<PageDetails {...props} />, options)
  }
})
