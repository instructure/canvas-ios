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
  .mock('../../../assignment-details/components/SubmissionBreakdownGraphSection')
  .mock('../../../assignment-details/components/PublishedIcon', () => 'PublishedIcon')

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/helm'),
}

describe('DiscussionDetails', () => {
  let props: Props
  beforeEach(() => {
    jest.clearAllMocks()
    let discussion = template.discussion({ id: '1' })
    props = {
      refresh: jest.fn(),
      refreshing: false,
      discussion: discussion,
      navigator: template.navigator(),
      discussionID: '1',
      courseID: '1',
      course: template.course({ id: 1 }),
      title: null,
      assignment: discussion.assignment,
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

  it('routes to the right place when due dates details is requested', () => {
    let navigator = template.navigator({
      show: jest.fn(),
    })
    let details = renderer.create(
      <DiscussionDetails {...props} navigator={navigator} />
    ).getInstance()
    details.viewDueDateDetails()
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/${props.assignment.id}/due_dates`,
      { modal: false },
      { onEditPressed: expect.any(Function) }
    )
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

  it('routes to discussion edit', () => {
    props.isAnnouncement = false
    props.navigator.show = jest.fn()
    props.courseID = '1'
    props.discussion = template.discussion({ id: '2' })
    const editButton: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    editButton.action()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/2/edit', { modal: true, modalPresentationStyle: 'formsheet' })
  })

  it('shows attachment', () => {
    // Appease flow
    if (props.discussion) {
      props.discussion = Object.assign(props.discussion, { attachments: [{}] })
    }
    let tree = render(props)

    tree.getInstance().showAttachment()

    expect(props.navigator.show).toHaveBeenCalledWith(
      '/attachment',
      { modal: true },
      { attachment: props.discussion.attachments[0] }
    )
  })

  function testRender (props: any) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: any) {
    return renderer.create(
      <DiscussionDetails {...props} />
    )
  }

  it('routes to the right place when submissions is tapped', () => {
    let navigator = template.navigator({
      push: jest.fn(),
    })
    let details = render({ ...props, navigator }).getInstance()
    details.viewAllSubmissions()
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/${props.assignment.id}/submissions`
    )
  })

  it('routes to the right place when submissions is tapped (via onPress)', () => {
    let navigator = template.navigator({
      push: jest.fn(),
    })
    let tree = render({ ...props, navigator }).toJSON()
    const doneButton = explore(tree).selectByID('discussions.submission-graphs') || {}
    doneButton.props.onPress()

    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/${props.assignment.id}/submissions`
    )
  })

  it('routes to the right place when submissions dial is tapped', () => {
    let navigator = template.navigator({
      push: jest.fn(),
    })
    let details = render({ ...props, navigator }).getInstance()
    details.onSubmissionDialPress('graded')
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/${props.assignment.id}/submissions`,
      { modal: false },
      { filterType: 'graded' }
    )
  })

  it('routes to the right place when edit is tapped from the due dates screen', () => {
    let navigator = template.navigator({
      push: jest.fn(),
    })
    let details = render({ ...props, navigator }).getInstance()
    details.editAssignment()
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/${props.assignment.id}/edit`,
      { modal: true, modalPresentationStyle: 'formsheet' },
    )
  })

  it('renders a non-assignment discussion', () => {
    let nonAssgProps = {
      ...props,
      discussion: {
        ...props.discussion,
        assignment: null,
      },
    }
    testRender(nonAssgProps)
  })
})

describe('mapStateToProps', () => {
  it('maps state to props', () => {
    const discussion = template.discussion({ id: '1', assignment_id: '1' })
    const assignment = template.assignment({ id: '1' })
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
        assignments: {
          '1': {
            data: assignment,
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
      assignment,
    })
  })

  it('maps state to props with null assignment data', () => {
    const discussion = template.discussion({ id: '1', assignment_id: '1' })
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
        assignments: {
          '2': {
            data: null,
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
