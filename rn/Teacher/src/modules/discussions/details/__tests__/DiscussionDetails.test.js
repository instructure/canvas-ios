/* @flow */

import React from 'react'
import {
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import renderer from 'react-test-renderer'

import { DiscussionDetails, mapStateToProps, type Props } from '../DiscussionDetails'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'

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
      courseName: 'HOTS For Dummies',
      courseColor: '#fff',
      title: null,
      assignment: discussion.assignment,
      deleteDiscussion: jest.fn(),
      pending: 0,
      error: null,
      refreshDiscussionEntries: jest.fn(),
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

  it('touches the reply button', () => {
    const navigator = template.navigator({
      show: jest.fn(),
    })
    const tree = renderer.create(<DiscussionDetails {...props} navigator={navigator} />).toJSON()
    const discussionReply: any = explore(tree).selectByID('discussion-reply')
    discussionReply.props.onPress()
    expect(navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/1/reply', { modal: true }, { parentIndexPath: [] })
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
    props.assignment = template.assignment({ id: '1' })
    let navigator = template.navigator({
      show: jest.fn(),
    })
    let details = renderer.create(
      <DiscussionDetails {...props} navigator={navigator} />
    ).getInstance()
    details.viewDueDateDetails()
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/1/due_dates`,
      { modal: false },
      { onEditPressed: expect.any(Function) }
    )
  })

  it('routes to announcement edit', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(0))
    props.isAnnouncement = true
    props.navigator.show = jest.fn()
    props.courseID = '1'
    props.discussion = template.discussion({ id: '2' })
    props.discussionID = '2'
    const editButton: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    editButton.action()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/announcements/2/edit', { modal: true, modalPresentationStyle: 'formsheet' })
  })

  it('right bar button shows options to edit or delete', () => {
    const mock = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = mock
    const kabob: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    kabob.action()
    expect(mock).toHaveBeenCalledWith(
      {
        options: ['Edit', 'Delete', 'Cancel'],
        destructiveButtonIndex: 1,
        cancelButtonIndex: 2,
      },
      expect.any(Function)
    )
  })

  it('alerts to confirm delete discussion', () => {
    // $FlowFixMe
    AlertIOS.alert = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    const kabob: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    kabob.action()
    expect(AlertIOS.alert).toHaveBeenCalledWith(
      'Are you sure you want to delete this discussion?',
      null,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'OK', onPress: expect.any(Function) },
      ],
    )
  })

  it('deletes discussion', () => {
    props.deleteDiscussion = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    // $FlowFixMe
    AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    props.courseID = '1'
    props.discussionID = '2'
    const kabob: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    kabob.action()
    expect(props.deleteDiscussion).toHaveBeenCalledWith('1', '2')
  })

  it('routes to discussion edit', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(0))
    props.isAnnouncement = false
    props.navigator.show = jest.fn()
    props.courseID = '1'
    props.discussion = template.discussion({ id: '2' })
    props.discussionID = '2'
    const editButton: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    editButton.action()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/2/edit', { modal: true, modalPresentationStyle: 'formsheet' })
  })

  it('routes to discussion edit on entry reply', () => {
    props.isAnnouncement = false
    props.navigator.show = jest.fn()
    props.courseID = '1'
    props.discussion = template.discussion({ id: '2' })

    let tree = render(props)
    tree.getInstance()._onPressReplyToEntry('3', [1, 0])
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/1/entries/3/replies', { modal: true }, { 'entryID': '3', 'parentIndexPath': [1, 0] })
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
      {
        // $FlowFixMe
        attachment: props.discussion.attachments[0],
      },
    )
  })

  it('routes to the right place when submissions is tapped', () => {
    props.assignment = template.assignment({ id: '1' })
    let navigator = template.navigator({
      push: jest.fn(),
    })
    let details = render({ ...props, navigator }).getInstance()
    details.viewAllSubmissions()
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/1/submissions`
    )
  })

  it('routes to the right place when submissions is tapped (via onPress)', () => {
    props.assignment = template.assignment({ id: '1' })
    let navigator = template.navigator({
      push: jest.fn(),
    })
    let tree = render({ ...props, navigator }).toJSON()
    const doneButton = explore(tree).selectByID('discussions.submission-graphs') || {}
    doneButton.props.onPress()

    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/1/submissions`
    )
  })

  it('routes to the right place when submissions dial is tapped', () => {
    props.assignment = template.assignment({ id: '1' })
    let navigator = template.navigator({
      push: jest.fn(),
    })
    let details = render({ ...props, navigator }).getInstance()
    details.onSubmissionDialPress('graded')
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/assignments/1/submissions`,
      { modal: false },
      { filterType: 'graded' }
    )
  })

  it('routes to the right place when edit is tapped from the due dates screen', () => {
    props.assignment = template.assignment({ id: '1' })
    let navigator = template.navigator({
      push: jest.fn(),
    })
    let details = render({ ...props, navigator }).getInstance()
    details._editDiscussion()
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/${props.courseID}/discussion_topics/1/edit`,
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

  it('pops after delete', () => {
    props.navigator.pop = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    // $FlowFixMe
    AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    const screen = render(props)
    const deleteDiscussion = jest.fn(() => {
      setProps(screen, { pending: 0, discussion: null })
    })
    screen.update(<DiscussionDetails {...props} deleteDiscussion={deleteDiscussion} />)
    const kabob: any = explore(screen.toJSON()).selectRightBarButton('discussions.details.edit.button')
    kabob.action()
    expect(props.navigator.pop).toHaveBeenCalled()
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
    const discussion = template.discussion({ id: '1', assignment_id: '1' })
    const assignment = template.assignment({ id: '1' })
    const course = template.course({ id: '1', name: 'Course' })
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
            color: '#fff',
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
      courseName: 'Course',
      courseColor: '#fff',
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
    })
  })
})
