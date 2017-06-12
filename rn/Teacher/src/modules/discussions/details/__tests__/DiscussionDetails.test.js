/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import { DiscussionDetails, mapStateToProps } from '../DiscussionDetails'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('WebView', () => 'WebView')
  .mock('../../../../routing')
  .mock('../../../../routing/Screen')

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/helm'),
}

describe('DiscussionDetails', () => {
  let props
  beforeEach(() => {
    jest.clearAllMocks()
    props = {
      refresh: jest.fn(),
      discussion: template.discussion({ id: '1' }),
      navigator: template.navigator(),
      discussionID: '1',
      courseID: '1',
      course: template.course({ id: 1 }),
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders without a discussion', () => {
    testRender({ ...props, discussion: null })
  })

  it('calls refresh on refresh', () => {
    props.refresh = jest.fn()
    const tree = render(props).toJSON()
    const refresher: any = explore(tree).query(({ type }) => type === 'RCTScrollView')[0]
    refresher.props.onRefresh()
    expect(props.refresh).toHaveBeenCalled()
  })

  function testRender (props: any) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: any) {
    return renderer.create(
      <DiscussionDetails {...props} />
    )
  }
})

describe('mapStateToProps', () => {
  it('maps state to props', () => {
    const discussion = template.discussion({ id: '1' })
    const course = template.course({ id: '1' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        discussions: {
          '1': {
            data: discussion,
            pending: 1,
            error: null,
          },
        },
        courses: {
          '1': {
            course: course,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1', discussionID: '1' })
    ).toMatchObject({
      discussion,
      pending: 1,
      error: null,
      courseID: '1',
      discussionID: '1',
      course,
    })
  })
})
