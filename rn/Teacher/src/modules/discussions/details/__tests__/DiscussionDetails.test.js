/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import { DiscussionDetails, mapStateToProps, type Props } from '../DiscussionDetails'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('WebView', () => 'WebView')
  .mock('../../../../routing')
  .mock('../../../../routing/Screen')
  .mock('../../../assignment-details/components/PublishedIcon', () => 'PublishedIcon')

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/helm'),
}

describe('DiscussionDetails', () => {
  let props: Props
  beforeEach(() => {
    jest.clearAllMocks()
    props = {
      refresh: jest.fn(),
      refreshing: false,
      discussion: template.discussion({ id: '1' }),
      navigator: template.navigator(),
      discussionID: '1',
      courseID: '1',
      course: template.course({ id: 1 }),
      title: null,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('sets title depending on announcement', () => {
    const title = (component) => {
      const screen: any = explore(render(props).toJSON()).query(({ type }) => type === 'Screen')[0]
      return screen.props.title
    }
    props.isAnnouncement = false
    expect(title(render(props))).toEqual('Discussion Details')

    props.isAnnouncement = true
    expect(title(render(props))).toEqual('Announcement Details')
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

  it('shows publish information', () => {
    expect(
      explore(render(props).toJSON()).selectByType('PublishedIcon')
    ).toBeDefined()
  })

  it('hides publish information for announcements', () => {
    props.isAnnouncement = true
    expect(
      explore(render(props).toJSON()).selectByType('PublishedIcon')
    ).not.toBeDefined()
  })

  it('routes to announcement edit', () => {
    props.isAnnouncement = true
    props.navigator.show = jest.fn()
    props.courseID = '1'
    props.discussion = template.discussion({ id: '2' })
    const editButton: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    editButton.action()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/announcements/2/edit', { modal: true, modalPresentationStyle: 'formsheet' })
  })

  it('does not route on edit if not an announcement', () => {
    props.isAnnouncement = false
    props.navigator.show = jest.fn()
    const editButton: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    editButton.action()
    expect(props.navigator.show).not.toHaveBeenCalled()
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
