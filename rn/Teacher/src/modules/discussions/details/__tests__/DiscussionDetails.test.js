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

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import {
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import renderer from 'react-test-renderer'

import { DiscussionDetails, mapStateToProps, shouldRefresh, type Props } from '../DiscussionDetails'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import app from '../../../app'
import { shallow } from 'enzyme'
import { alertError } from '../../../../redux/middleware/error-handler'
import * as template from '../../../../__templates__'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('WebView', () => 'WebView')
  .mock('../../../../common/components/Avatar', () => 'Avatar')
  .mock('../../../../routing')
  .mock('../../../../routing/Screen')
  .mock('../../../assignment-details/components/SubmissionBreakdownGraphSection', () => 'SubmissionBreakdownGraphSection')
  .mock('../../../assignment-details/components/PublishedIcon', () => 'PublishedIcon')
  .mock('LayoutAnimation', () => ({
    easeInEaseOut: jest.fn(),
  }))
  .mock('../../../app', () => ({
    isTeacher: jest.fn(),
  }))
  .mock('../../../../redux/middleware/error-handler', () => {
    return { alertError: jest.fn() }
  })

jest.useFakeTimers()

describe('DiscussionDetails', () => {
  let props: Props
  beforeEach(() => {
    jest.clearAllMocks()
    app.isTeacher = jest.fn(() => true)
    let discussion = template.discussion({ id: '1', replies: [template.discussionReply()], participants: { [template.userDisplay().id]: template.userDisplay() } })
    props = {
      refresh: jest.fn(),
      refreshing: false,
      discussion: discussion,
      navigator: template.navigator(),
      discussionID: '1',
      context: 'courses',
      contextID: '1',
      courseName: 'HOTS For Dummies',
      courseColor: '#fff',
      title: null,
      assignment: discussion.assignment,
      deleteDiscussion: jest.fn(),
      deleteDiscussionEntry: jest.fn(),
      pending: 0,
      error: null,
      refreshDiscussionEntries: jest.fn(),
      refreshSingleDiscussion: jest.fn(),
      markAllAsRead: jest.fn(),
      markEntryAsRead: jest.fn(),
      unreadEntries: [],
    }
  })

  it('renders with no discussion', () => {
    let newProps = {
      ...props,
      discussion: undefined,
    }
    testRender(newProps)
  })

  it('renders in student app', () => {
    app.isTeacher = jest.fn(() => false)
    testRender(props)
  })

  it('renders section names for section specific announcements', () => {
    let discussion = template.discussion({
      replies: [template.discussionReply()],
      participants: {
        [template.userDisplay().id]: template.userDisplay(),
      },
      is_section_specific: true,
      sections: [template.section({ name: 'A Section' })],
    })

    let view = shallow(
      new DiscussionDetails({
        ...props,
        discussion,
      }).renderDetails(discussion)
    )
    let subtitle = view.find('SubTitle')
    expect(subtitle.props().children).toContain('A Section')
  })

  it('renders closed discussion as student', () => {
    app.isTeacher = jest.fn(() => false)
    props.discussion.locked_for_user = true
    testRender(props)
  })

  it('renders with replies', () => {
    testRender(props)
  })

  it('renders no replies', () => {
    props.discussion = template.discussion({ id: '1' })
    testRender(props)
  })

  it('renders with nested replies selected', () => {
    let aaaaa = template.discussionReply({ id: '5' })
    let aaaa = template.discussionReply({ id: '4', replies: [aaaaa] })
    let aaa = template.discussionReply({ id: '3', replies: [aaaa] })
    let aa = template.discussionReply({ id: '2', replies: [aaa] })
    let a = template.discussionReply({ id: '1', replies: [aa] })
    let discussion = { ...props.discussion, replies: [a] }
    const tree = render({ ...props, discussion })
    const instance = tree.getInstance()
    instance._onPressMoreReplies([0, 0, 0, 0])
    expect(tree.toJSON()).toMatchSnapshot()
    expect(instance.state).toMatchObject({
      deletePending: false,
      rootNodePath: [0, 0, 0, 0],
      maxReplyNodeDepth: 2,
      unread_entries: [],
      entry_ratings: {},
    })

    let rootNodes = instance.rootRepliesData(discussion, [0, 0, 0, 0])
    let expected = [{
      ...aaaa,
      depth: 0,
      readState: 'read',
      myPath: [0],
      rating: undefined,
    }, {
      ...aaaaa,
      depth: 1,
      readState: 'read',
      myPath: [0, 0],
      rating: undefined,
    },
    ]
    expect(rootNodes).toEqual(expected)
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
    expect(navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/1/reply', { modal: true }, {
      indexPath: [],
      lastReplyAt: props.discussion && props.discussion.last_reply_at,
      permissions: props.discussion && props.discussion.permissions,
    })
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
      `/courses/${props.contextID}/assignments/1/due_dates`,
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

  it('right bar button shows options', () => {
    const mock = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = mock
    const kabob: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    kabob.action()
    expect(mock).toHaveBeenCalledWith(
      {
        options: ['Edit', 'Mark All as Read', 'Delete', 'Cancel'],
        destructiveButtonIndex: 2,
        cancelButtonIndex: 3,
      },
      expect.any(Function)
    )
  })

  it('calls markAllAsRead when that option is selected', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))

    const kabob: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    kabob.action()
    expect(props.markAllAsRead).toHaveBeenCalledWith('courses', '1', '1', 1)
  })

  it('alerts to confirm delete discussion', () => {
    // $FlowFixMe
    AlertIOS.alert = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(2))
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

  it('alerts to confirm delete reply', () => {
    // $FlowFixMe
    AlertIOS.alert = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    const tree = render(props).getInstance()
    tree._confirmDeleteReply('1', '1', '1')
    expect(AlertIOS.alert).toHaveBeenCalledWith(
      'Are you sure you want to delete this reply?',
      null,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'OK', onPress: expect.any(Function) },
      ],
    )
  })

  it('deletes discussion reply', () => {
    props.deleteDiscussionEntry = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    // $FlowFixMe
    AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    const tree = render(props).getInstance()
    tree._confirmDeleteReply('1', '1', '1', [0, 1])
    expect(props.deleteDiscussionEntry).toHaveBeenCalledWith('1', '1', '1', [0, 1])
  })

  it('marks unread entry as read when viewable', () => {
    let a = template.discussionReply({ id: '0', readState: 'unread' })
    let discussion = { ...props.discussion, replies: [a] }
    const tree = render({ ...props, discussion })
    const instance = tree.getInstance()
    instance.setState({ unread_entries: ['0'] })

    let info = {
      viewableItems: [{
        isViewable: true,
        index: 0,
        item: a,
      }],
      changed: [{
        isViewable: true,
        index: 0,
        item: a,
      }],
    }
    instance._markViewableAsRead(info)
    jest.runAllTimers()
    expect(props.markEntryAsRead).toHaveBeenCalledWith('courses', '1', '1', '0')
  })

  it('does not marks unread entry as read when not in view', () => {
    let a = template.discussionReply({ id: '0', readState: 'unread' })
    let discussion = { ...props.discussion, replies: [a] }
    const tree = render({ ...props, discussion })
    const instance = tree.getInstance()
    instance.setState({ unread_entries: ['0'] })

    let info = {
      viewableItems: [{
        isViewable: false,
        index: 0,
        item: a,
      }],
      changed: [{
        isViewable: false,
        index: 0,
        item: a,
      }],
    }
    instance._markViewableAsRead(info)
    jest.runAllTimers()
    expect(props.markEntryAsRead).toHaveBeenCalledTimes(0)
  })

  it('does not call markEntryAsRead action if it has already been read', () => {
    let a = template.discussionReply({ id: '0', readState: 'read' })
    let discussion = { ...props.discussion, replies: [a] }
    const tree = render({ ...props, discussion })
    const instance = tree.getInstance()
    instance.setState({ unread_entries: ['2', '3'] })

    let info = {
      viewableItems: [{
        isViewable: true,
        index: 0,
        item: a,
      }],
      changed: [{
        isViewable: true,
        index: 0,
        item: a,
      }],
    }
    instance._markViewableAsRead(info)
    jest.runAllTimers()
    expect(props.markEntryAsRead).toHaveBeenCalledTimes(0)
  })

  it('catches the discussion details section when on screen so it doesnt try to mark as read', () => {
    let a = template.discussionReply({ id: '1', readState: 'unread' })
    let discussion = { ...props.discussion, replies: [a] }
    const tree = render({ ...props, discussion })
    const instance = tree.getInstance()
    instance.setState({ unread_entries: ['0'] })

    let info = {
      viewableItems: [{
        isViewable: true,
        index: 0,
        item: a,
      }],
      changed: [{
        isViewable: true,
        index: 0,
        item: a,
      }],
    }
    instance._markViewableAsRead(info)
    jest.runAllTimers()
    expect(props.markEntryAsRead).toHaveBeenCalledTimes(0)
  })

  it('calls refreshSingleDiscussion on unmount to update unread count', () => {
    props.refreshSingleDiscussion = jest.fn()
    render(props).getInstance().componentWillUnmount()
    expect(props.refreshSingleDiscussion).toHaveBeenCalledWith(props.context, props.contextID, props.discussionID)
  })

  it('does not call refreshSingleDiscussion on unmount if no discussion (was deleted)', () => {
    let newProps = {
      ...props,
      discussion: null,
    }
    newProps.refreshSingleDiscussion = jest.fn()
    render(newProps).getInstance().componentWillUnmount()
    expect(newProps.refreshSingleDiscussion).not.toHaveBeenCalledWith()
  })

  it('_onPopReplyRootPath pops to correct set of replies', () => {
    let aaaaaaaaa = template.discussionReply({ id: '9' })
    let aaaaaaaa = template.discussionReply({ id: '8', replies: [aaaaaaaaa] })
    let aaaaaaa = template.discussionReply({ id: '7', replies: [aaaaaaaa] })
    let aaaaaa = template.discussionReply({ id: '6', replies: [aaaaaaa] })
    let aaaaa = template.discussionReply({ id: '5', replies: [aaaaaa] })
    let aaaa = template.discussionReply({ id: '4', replies: [aaaaa] })
    let aaa = template.discussionReply({ id: '3', replies: [aaaa] })
    let aa = template.discussionReply({ id: '2', replies: [aaa] })
    let a = template.discussionReply({ id: '1', replies: [aa] })
    let discussion = { ...props.discussion, replies: [a] }
    const tree = render({ ...props, discussion })
    const instance = tree.getInstance()
    instance._onPressMoreReplies([0, 0, 0, 0])
    instance._onPressMoreReplies([0, 0, 0, 0, 0, 0, 0])
    expect(instance.state).toMatchObject({ deletePending: false, rootNodePath: [0, 0, 0, 0, 0, 0, 0], maxReplyNodeDepth: 2, unread_entries: [] })
    instance._onPopReplyRootPath()
    expect(instance.state).toMatchObject({ deletePending: false, rootNodePath: [0, 0, 0, 0, 0], maxReplyNodeDepth: 2, unread_entries: [] })
    instance._onPopReplyRootPath()
    expect(instance.state).toMatchObject({ deletePending: false, rootNodePath: [0, 0, 0], maxReplyNodeDepth: 2, unread_entries: [] })
    instance._onPopReplyRootPath()
    expect(instance.state).toMatchObject({ deletePending: false, rootNodePath: [], maxReplyNodeDepth: 2, unread_entries: [] })
  })

  it('deletes discussion', () => {
    props.deleteDiscussion = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(2))
    // $FlowFixMe
    AlertIOS.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    props.courseID = '1'
    props.discussionID = '2'
    const kabob: any = explore(render(props).toJSON()).selectRightBarButton('discussions.details.edit.button')
    kabob.action()
    expect(props.deleteDiscussion).toHaveBeenCalledWith('courses', '1', '2')
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

    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/1/entries/3/replies', { modal: true }, {
      'entryID': '3',
      'indexPath': [1, 0],
      lastReplyAt: props.discussion && props.discussion.last_reply_at,
      permissions: props.discussion && props.discussion.permissions,
    })
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
      `/courses/${props.contextID}/assignments/1/submissions`
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
      `/courses/${props.contextID}/assignments/1/submissions`
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
      `/courses/${props.contextID}/assignments/1/submissions`,
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
      `/courses/${props.contextID}/discussion_topics/1/edit`,
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

  it('pops after delete without refresh', () => {
    props.navigator.pop = jest.fn()
    props.refreshSingleDiscussion = jest.fn()
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(2))
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
    expect(props.refreshSingleDiscussion).not.toHaveBeenCalled()
  })

  it('displays delayed post at date', () => {
    props.discussion = template.discussion({
      delayed_post_at: '3019-10-28T14:16:00-07:00',
      posted_at: '2017-10-27T14:16:00-07:00',
    })
    const label: any = explore(render(props).toJSON()).selectByID('discussion.details.post-date-lbl')
    expect(label.children).toEqual(['Oct 28 at 3:16 PM'])
  })

  it('displays post date', () => {
    props.discussion = template.discussion({
      delayed_post_at: null,
      posted_at: '2017-10-27T14:16:00-07:00',
    })
    const label: any = explore(render(props).toJSON()).selectByID('discussion.details.post-date-lbl')
    expect(label.children).toEqual(['Oct 27 at 3:16 PM'])
  })

  it('navigates to context card when pressing the avatar', () => {
    let avatar = explore(render(props).toJSON()).selectByID('discussion.details.avatar') || {}
    avatar.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith(
      `/courses/1/users/1`,
      { modal: true },
    )
  })

  it('does not show require_initial_post message on render', () => {
    props.requireInitialPost = false
    const details = shallow(new DiscussionDetails(props).renderDetails(props.discussion))
    expect(details.find('[testID="discussions.details.require_initial_post.message"]')).toHaveLength(0)
  })

  it('shows require_initial_post message', () => {
    props.initialPostRequired = true
    props.discussion = template.discussion()
    const screen = shallow(<DiscussionDetails {...props} />)
    const details = shallow(screen.instance().renderDetails(props.discussion))
    expect(details.find('[testID="discussions.details.require_initial_post.message"]')).toHaveLength(1)
  })

  it('alerts error', () => {
    const screen = shallow(<DiscussionDetails {...props} />)
    screen.setProps({ error: 'ERROR!' })
    expect(alertError).toHaveBeenCalledWith('ERROR!')
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
            entry_ratings: { '4': 1 },
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
      mapStateToProps(state, { context: 'courses', contextID: '1', discussionID: '1' })
    ).toMatchObject({
      discussion,
      pending: 1,
      error: null,
      context: 'courses',
      contextID: '1',
      discussionID: '1',
      courseName: 'Course',
      courseColor: '#fff',
      assignment,
      isAnnouncement: false,
      entryRatings: { '4': 1 },
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
      mapStateToProps(state, { context: 'courses', contextID: '1', discussionID: '1' })
    ).toMatchObject({
      discussion,
      pending: 1,
      error: null,
      context: 'courses',
      contextID: '1',
      discussionID: '1',
    })
  })

  it('handles announcementID route prop', () => {
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
      mapStateToProps(state, { context: 'courses', contextID: '1', announcementID: '1' })
    ).toMatchObject({
      discussion,
      pending: 1,
      error: null,
      context: 'courses',
      contextID: '1',
      discussionID: '1',
      isAnnouncement: true,
    })
  })
})

describe('shouldRefresh', () => {
  it('should refresh if discussion allows ratings', () => {
    const props = {
      discussion: template.discussion({
        replies: [template.discussionReply()],
        assignment_id: null,
        unread_count: 0,
      }),
      unreadEntries: null,
    }

    props.allow_rating = false
    expect(shouldRefresh(props)).toBeFalsy()

    props.discussion.allow_rating = true
    expect(shouldRefresh(props)).toBeTruthy()
  })
})
