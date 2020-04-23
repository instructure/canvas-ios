//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import {
  ActionSheetIOS,
  Alert,
  NativeModules,
} from 'react-native'

import { DiscussionDetails, mapStateToProps, shouldRefresh, type Props } from '../DiscussionDetails'
import app from '../../../app'
import { shallow } from 'enzyme'
import { alertError } from '../../../../redux/middleware/error-handler'
import * as template from '../../../../__templates__'

jest
  .mock('../../../../routing')
  .mock('react-native/Libraries/LayoutAnimation/LayoutAnimation', () => ({
    easeInEaseOut: jest.fn(),
  }))
  .mock('../../../../redux/middleware/error-handler', () => {
    return { alertError: jest.fn() }
  })
  .mock('../../../assignment-details/components/SubmissionBreakdownGraphSection.js', () => 'SubmissionBreakdownGraphSection')

jest.useFakeTimers()

describe('DiscussionDetails', () => {
  let props: Props
  beforeEach(() => {
    jest.clearAllMocks()
    jest.useFakeTimers()
    app.setCurrentApp('teacher')
    let discussion = template.discussion({
      id: '1',
      replies: [template.discussionReply()],
      participants: {
        [template.userDisplay().id]: template.userDisplay(),
      },
      assignment: template.assignment({ course_id: '1' }),
    })
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
      markTopicAsRead: jest.fn(),
      unreadEntries: [],
      permissions: { post_to_forum: true },
      isAnnouncement: false,
    }
  })

  it('captures trait changes', () => {
    let horizontal = 'wide'
    props.navigator.traitCollection = (cb) => {
      cb({ window: { horizontal } })
    }

    let tree = shallow(<DiscussionDetails {...props} />)
    let screen = tree.find('Screen')
    screen.simulate('traitCollectionChange')
    expect(tree.state('maxReplyNodeDepth')).toEqual(2)

    horizontal = 'regular'
    screen.simulate('traitCollectionChange')
    expect(tree.state('maxReplyNodeDepth')).toEqual(4)
  })

  it('sets title depending on announcement', () => {
    let tree = shallow(<DiscussionDetails {...props} isAnnouncement={false} />)
    expect(tree.find('Screen').prop('title')).toEqual('Discussion Details')

    tree.setProps({
      ...props,
      isAnnouncement: true,
    })
    expect(tree.find('Screen').prop('title')).toEqual('Announcement Details')
  })

  it('renders the navbar color and subtitle from the course', () => {
    let tree = shallow(
      <DiscussionDetails
        {...props}
        courseColor='#fff'
        courseName='Course name'
      />
    )
    expect(tree.find('Screen').props()).toMatchObject({
      navBarColor: '#fff',
      subtitle: 'Course name',
    })
  })

  describe('kabob', () => {
    function getKabob (tree) {
      return tree.find('Screen').prop('rightBarButtons')[0]
    }
    it('does not show in student app', () => {
      app.setCurrentApp('student')
      let tree = shallow(<DiscussionDetails {...props} />)
      expect(tree.find('Screen').prop('rightBarButtons')).toBeFalsy()
    })

    it('right bar button shows options', () => {
      ActionSheetIOS.showActionSheetWithOptions = jest.fn()
      let tree = shallow(<DiscussionDetails {...props} />)
      let kabob = getKabob(tree)
      kabob.action()
      expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalledWith(
        {
          options: ['Edit', 'Mark All as Read', 'Delete', 'Cancel'],
          destructiveButtonIndex: 2,
          cancelButtonIndex: 3,
        },
        expect.any(Function)
      )
    })

    it('edit announcement', () => {
      ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(0))
      let discussion = template.discussion({ id: '2' })
      let tree = shallow(
        <DiscussionDetails
          {...props}
          isAnnouncement
          discussion={discussion}
          discussionID = '2'
        />
      )
      let kabob = getKabob(tree)
      kabob.action()
      expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/announcements/2/edit', { modal: true, modalPresentationStyle: 'formsheet' })
    })

    it('edit discussion', () => {
      ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(0))
      let discussion = template.discussion({ id: '2' })
      let tree = shallow(
        <DiscussionDetails
          {...props}
          discussion={discussion}
          discussionID = '2'
        />
      )
      let kabob = getKabob(tree)
      kabob.action()
      expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/2/edit', { modal: true, modalPresentationStyle: 'formsheet' })
    })

    it('calls markAllAsRead when that option is selected', () => {
      ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
      let tree = shallow(<DiscussionDetails {...props} />)
      let kabob = getKabob(tree)
      kabob.action()
      expect(props.markAllAsRead).toHaveBeenCalledWith('courses', '1', '1', 1)
    })

    it('alerts to confirm delete discussion', () => {
      Alert.alert = jest.fn()
      ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(2))

      let tree = shallow(<DiscussionDetails {...props} />)
      let kabob = getKabob(tree)
      kabob.action()
      expect(Alert.alert).toHaveBeenCalledWith(
        'Are you sure you want to delete this discussion?',
        null,
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'OK', onPress: expect.any(Function) },
        ],
      )
    })

    it('deletes discussion', () => {
      ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(2))
      Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
      let tree = shallow(
        <DiscussionDetails
          {...props}
          courseID='1'
          discussionID='2'
        />
      )
      let kabob = getKabob(tree)
      kabob.action()
      expect(props.deleteDiscussion).toHaveBeenCalledWith('courses', '1', '2')
    })
  })

  it('FlatList refreshes', () => {
    let tree = shallow(<DiscussionDetails {...props} />)
    tree.find('FlatList').simulate('refresh')
    expect(props.refresh).toHaveBeenCalled()
  })

  it('has the right data', () => {
    let aaaaa = template.discussionReply({ id: '5' })
    let aaaa = template.discussionReply({ id: '4', replies: [aaaaa] })
    let aaa = template.discussionReply({ id: '3', replies: [aaaa] })
    let aa = template.discussionReply({ id: '2', replies: [aaa] })
    let a = template.discussionReply({ id: '1', replies: [aa] })
    let discussion = { ...props.discussion, replies: [a] }
    let tree = shallow(<DiscussionDetails {...props} discussion={discussion} />)
    expect(tree.find('FlatList').prop('data')).toMatchObject([{
      id: '1',
      myPath: [0],
    }, {
      id: '2',
      myPath: [0, 0],
    }, {
      id: '3',
      myPath: [0, 0, 0],
    }])
  })

  it('does not render the ListHeaderComponent with no discussion', () => {
    let tree = shallow(<DiscussionDetails {...props} discussion={null} />)
    expect(tree.find('FlatList').prop('ListHeaderComponent')).toBeFalsy()

    tree.setProps({
      ...props,
      discussion: template.discussion(),
    })
    expect(tree.find('FlatList').prop('ListHeaderComponent')).not.toBeFalsy()
  })

  describe('mark entry as read', () => {
    it('marks unread entry as read when viewable', () => {
      let a = template.discussionReply({ id: '0', readState: 'unread' })
      let discussion = { ...props.discussion, replies: [a] }
      let tree = shallow(<DiscussionDetails { ...props } discussion={discussion} />)
      tree.setState({ unread_entries: ['0'] })

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
      tree.instance()._markViewableAsRead(info)
      jest.runAllTimers()
      expect(props.markEntryAsRead).toHaveBeenCalledWith('courses', '1', '1', '0')
    })

    it('does not marks unread entry as read when not in view', () => {
      let a = template.discussionReply({ id: '0', readState: 'unread' })
      let discussion = { ...props.discussion, replies: [a] }
      let tree = shallow(<DiscussionDetails { ...props } discussion={discussion} />)
      tree.setState({ unread_entries: ['0'] })

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
      tree.instance()._markViewableAsRead(info)
      jest.runAllTimers()
      expect(props.markEntryAsRead).toHaveBeenCalledTimes(0)
    })

    it('does not call markEntryAsRead action if it has already been read', () => {
      let a = template.discussionReply({ id: '0', readState: 'read' })
      let discussion = { ...props.discussion, replies: [a] }
      const tree = shallow(<DiscussionDetails { ...props } discussion={discussion} />)
      tree.setState({ unread_entries: ['2', '3'] })

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
      tree.instance()._markViewableAsRead(info)
      jest.runAllTimers()
      expect(props.markEntryAsRead).toHaveBeenCalledTimes(0)
    })

    it('catches the discussion details section when on screen so it doesnt try to mark as read', () => {
      let a = template.discussionReply({ id: '1', readState: 'unread' })
      let discussion = { ...props.discussion, replies: [a] }
      let tree = shallow(<DiscussionDetails { ...props } discussion={discussion} />)
      tree.setState({ unread_entries: ['0'] })

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
      tree.instance()._markViewableAsRead(info)
      jest.runAllTimers()
      expect(props.markEntryAsRead).toHaveBeenCalledTimes(0)
    })
  })

  describe('details', () => {
    function renderDetails (props) {
      return shallow(new DiscussionDetails(props).renderDetails(props.discussion))
    }

    test('title', () => {
      let tree = renderDetails({
        ...props,
        discussion: template.discussion({ title: null }),
      })
      expect(tree.find('[testID="DiscussionDetails.titleLabel"]').prop('children')).toEqual('No Title')

      tree = renderDetails(props)
      expect(tree.find('[testID="DiscussionDetails.titleLabel"]').prop('children')).toEqual(props.discussion.title)
    })

    test('points_possible', () => {
      let tree = renderDetails({ ...props, isAnnouncement: true })
      expect(tree.find('[testID="DiscussionDetails.pointsLabel"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        isAnnouncement: false,
        discussion: template.discussion({ assignment: null }),
      })
      expect(tree.find('[testID="DiscussionDetails.pointsLabel"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        isAnnouncement: false,
        discussion: template.discussion({
          assignment: template.assignment({ points_possible: 50 }),
        }),
      })
      expect(tree.find('[testID="DiscussionDetails.pointsLabel"]').prop('children')).toEqual('50 pts')
    })

    test('published', () => {
      let tree = renderDetails({ ...props, isAnnouncement: true })
      expect(tree.find('PublishedIcon').exists()).toEqual(false)

      app.setCurrentApp('student')
      tree = renderDetails({
        ...props,
        isAnnouncement: false,
      })
      expect(tree.find('PublishedIcon').exists()).toEqual(false)
      app.setCurrentApp('teacher')
      tree = renderDetails({
        ...props,
        isAnnouncement: false,
      })
      expect(tree.find('PublishedIcon').prop('published')).toEqual(props.discussion.published)
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

      let view = renderDetails({
        ...props,
        discussion,
      })
      let subtitle = view.find('SubTitle')
      expect(subtitle.props().children).toContain('A Section')
    })

    test('due dates', () => {
      app.setCurrentApp('student')
      let tree = renderDetails({ ...props, assignment: null })
      expect(tree.find('[testID="DiscussionDetails.dueDates"]').exists()).toEqual(false)

      app.setCurrentApp('teacher')
      tree = renderDetails({ ...props, assignment: null })
      expect(tree.find('[testID="DiscussionDetails.dueDates"]').exists()).toEqual(false)

      tree = renderDetails({ ...props, assignment: template.assignment() })
      expect(tree.find('[testID="DiscussionDetails.dueDates"]').exists()).toEqual(true)
    })

    it('routes to the right place when due dates details is requested', () => {
      let tree = shallow(
        <DiscussionDetails {...props} assignment={template.assignment({ id: '1', course_id: '1' })} />
      )

      let details = shallow(tree.instance().renderDetails(props.discussion))
      details.find('[testID="DiscussionDetails.dueDates"]').simulate('press')
      expect(props.navigator.show).toHaveBeenCalledWith(
        `/courses/${props.contextID}/assignments/1/due_dates`,
        { modal: false },
        { onEditPressed: tree.instance()._editDiscussion }
      )
    })

    test('submission graphs', () => {
      app.setCurrentApp('student')
      let tree = renderDetails(props)
      expect(tree.find('[testID="DiscussionDetails.submissionGraphs"]').exists()).toEqual(false)

      app.setCurrentApp('teacher')
      tree = renderDetails({
        ...props,
        assignment: null,
      })
      expect(tree.find('[testID="DiscussionDetails.submissionGraphs"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        assignment: template.assignment(),
        discussion: template.discussion({ group_topic_children: 0 }),
      })
      expect(tree.find('[testID="DiscussionDetails.submissionGraphs"]').exists()).toEqual(true)
    })

    it('routes to the right place when submissions is tapped (via onPress)', () => {
      let tree = renderDetails({
        ...props,
        assignment: template.assignment({ id: '1', course_id: '22' }),
      })
      tree.find('[testID="DiscussionDetails.submissionGraphs"]').simulate('press')

      expect(props.navigator.show).toHaveBeenCalledWith(
        `/courses/22/assignments/1/submissions`
      )
    })

    it('routes to the right place when submissions dial is tapped', () => {
      let tree = renderDetails({
        ...props,
        assignment: template.assignment({ id: '1', course_id: '85' }),
      })

      tree.find('SubmissionBreakdownGraphSection').simulate('press', 'graded')
      expect(props.navigator.show).toHaveBeenCalledWith(
        `/courses/85/assignments/1/submissions`,
        { modal: false },
        { filterType: 'graded' }
      )
    })

    test('avatar', () => {
      let tree = renderDetails({
        ...props,
        discussion: template.discussion({ author: null }),
      })
      expect(tree.find('Avatar').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        discussion: template.discussion({ author: template.user({ display_name: null }) }),
      })
      expect(tree.find('Avatar').exists()).toEqual(false)

      let user = template.userDisplay()
      tree = renderDetails({
        ...props,
        discussion: template.discussion({
          author: user,
        }),
      })
      let avatar = tree.find('Avatar')
      expect(avatar.props()).toMatchObject({
        avatarURL: user.avatar_image_url,
        userName: user.display_name,
      })
    })

    test('author', () => {
      let tree = renderDetails({
        ...props,
        discussion: template.discussion({ author: null }),
      })
      expect(tree.find('[testID="DiscussionDetails.authorName"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        discussion: template.discussion({ author: template.user({ display_name: null }) }),
      })
      expect(tree.find('[testID="DiscussionDetails.authorName"]').exists()).toEqual(false)

      let user = template.userDisplay({ display_name: 'Eve' })
      tree = renderDetails({
        ...props,
        discussion: template.discussion({
          author: user,
        }),
      })
      expect(tree.find('[testID="DiscussionDetails.authorName"]').prop('children')).toEqual('Eve')

      user = template.userDisplay({ display_name: 'Eve', pronouns: 'She/Her' })
      tree = renderDetails({
        ...props,
        discussion: template.discussion({
          author: user,
        }),
      })
      expect(tree.find('[testID="DiscussionDetails.authorName"]').prop('children')).toEqual('Eve (She/Her)')
    })

    it('navigates to context card when pressing the avatar', () => {
      let tree = renderDetails(props)
      let avatar = tree.find('[testID="DiscussionDetails.avatar"]')
      avatar.simulate('press')
      expect(props.navigator.show).toHaveBeenCalledWith(
        `/courses/1/users/1`,
        { modal: true },
      )
    })

    it('displays delayed post at date', () => {
      props.discussion = template.discussion({
        delayed_post_at: '3019-10-28T14:16:00-07:00',
        posted_at: '2017-10-27T14:16:00-07:00',
      })
      const label = renderDetails(props).find('[testID="DiscussionDetails.postDateLabel"]')
      expect(label.prop('children')).toEqual('Oct 28 at 3:16 PM')
    })

    it('displays post date', () => {
      props.discussion = template.discussion({
        delayed_post_at: null,
        posted_at: '2017-10-27T14:16:00-07:00',
      })
      const label = renderDetails(props).find('[testID="DiscussionDetails.postDateLabel"]')
      expect(label.prop('children')).toEqual('Oct 27 at 3:16 PM')
    })

    it('displays no post date', () => {
      props.discussion = template.discussion({
        delayed_post_at: null,
        posted_at: null,
      })
      const label = renderDetails(props).find('[testID="DiscussionDetails.postDateLabel"]')
      expect(label.exists()).toEqual(false)
    })

    test('CanvasWebView', () => {
      let tree = renderDetails(props)
      expect(tree.find('CanvasWebView').prop('html')).toEqual(props.discussion.message)
    })

    test('attachment', () => {
      let tree = renderDetails({
        ...props,
        discussion: template.discussion({ attachments: null }),
      })
      expect(tree.find('[testID="DiscussionDetails.attachmentButton"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        discussion: template.discussion({ attachments: [] }),
      })
      expect(tree.find('[testID="DiscussionDetails.attachmentButton"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        discussion: template.discussion({ attachments: [template.attachment()] }),
      })
      expect(tree.find('[testID="DiscussionDetails.attachmentButton"]').exists()).toEqual(true)
    })

    it('navigates to attachment', () => {
      let attachment = template.attachment()
      let tree = renderDetails({
        ...props,
        discussion: template.discussion({ attachments: [attachment] }),
      })
      tree.find('[testID="DiscussionDetails.attachmentButton"]').simulate('press')
      expect(props.navigator.show).toHaveBeenCalledWith(
        '/attachment',
        { modal: true },
        { attachment },
      )
    })

    test('reply button', () => {
      let tree = renderDetails({
        ...props,
        discussion: template.discussion({ locked_for_user: true }),
        permissions: { post_to_forum: false },
      })
      expect(tree.find('[testID="DiscussionDetails.replyButton"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        discussion: template.discussion({ locked_for_user: false }),
        permissions: { post_to_forum: false },
      })
      expect(tree.find('[testID="DiscussionDetails.replyButton"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        discussion: template.discussion({ locked_for_user: false }),
        permissions: { post_to_forum: true },
      })
      expect(tree.find('[testID="DiscussionDetails.replyButton"]').exists()).toEqual(true)
    })

    it('touches the reply button', () => {
      const tree = renderDetails(props)
      const discussionReply = tree.find('[testID="DiscussionDetails.replyButton"]')
      discussionReply.simulate('press')
      expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/1/reply', { modal: true, disableSwipeDownToDismissModal: true }, {
        indexPath: [],
        lastReplyAt: props.discussion && props.discussion.last_reply_at,
        permissions: props.discussion && props.discussion.permissions,
      })
    })

    describe('GroupTopicChildren', () => {
      beforeEach(() => {
        app.setCurrentApp('teacher')
        props.context = 'courses'
        props.discussion.group_topic_children = [{ id: '1', group_id: '2' }]
        props.groups = {}
      })

      it('renders GroupTopicChildren', () => {
        const details = shallow(new DiscussionDetails(props).renderDetails(props.discussion))
        expect(details.find('GroupTopicChildren')).not.toBeNull()
      })

      it('does not render GroupTopicChildren in groups context', () => {
        props.context = 'groups'
        const details = shallow(new DiscussionDetails(props).renderDetails(props.discussion))
        expect(details.find('GroupTopicChildren')).toHaveLength(0)
      })

      it('does not render GroupTopicChildren if student', () => {
        app.setCurrentApp('student')
        const details = shallow(new DiscussionDetails(props).renderDetails(props.discussion))
        expect(details.find('GroupTopicChildren')).toHaveLength(0)
      })

      it('does not render GroupTopicChildren if there are no children', () => {
        props.discussion.group_topic_children = []
        const details = shallow(new DiscussionDetails(props).renderDetails(props.discussion))
        expect(details.find('GroupTopicChildren')).toHaveLength(0)
      })
    })

    test('replies heading', () => {
      let tree = renderDetails({
        ...props,
        discussion: template.discussion({ replies: null }),
      })
      expect(tree.find('[testID="DiscussionDetails.repliesHeading"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        discussion: template.discussion({ replies: [] }),
      })
      expect(tree.find('[testID="DiscussionDetails.repliesHeading"]').exists()).toEqual(false)

      tree = renderDetails({
        ...props,
        discussion: template.discussion({ replies: [template.discussionReply()] }),
      })
      expect(tree.find('[testID="DiscussionDetails.repliesHeading"]').exists()).toEqual(true)
    })

    it('doesnt show the pop reply button with no replies', () => {
      let discussion = template.discussion({ replies: [] })
      let tree = shallow(<DiscussionDetails {...props} discussion={discussion} />)
      let details = shallow(tree.instance().renderDetails(discussion))
      expect(details.find('[testID="discussion.popToLastDiscussionList"]').exists()).toEqual(false)
    })

    test('popReply', () => {
      let aaaaaaaaa = template.discussionReply({ id: '9' })
      let aaaaaaaa = template.discussionReply({ id: '8', replies: [aaaaaaaaa] })
      let aaaaaaa = template.discussionReply({ id: '7', replies: [aaaaaaaa] })
      let aaaaaa = template.discussionReply({ id: '6', replies: [aaaaaaa] })
      let aaaaa = template.discussionReply({ id: '5', replies: [aaaaaa] })
      let aaaa = template.discussionReply({ id: '4', replies: [aaaaa] })
      let aaa = template.discussionReply({ id: '3', replies: [aaaa] })
      let aa = template.discussionReply({ id: '2', replies: [aaa] })
      let a = template.discussionReply({ id: '1', replies: [aa] })
      let discussion = template.discussion({ replies: [a] })

      let tree = shallow(<DiscussionDetails {...props} discussion={discussion} />)
      tree.instance()._onPressMoreReplies([0, 0, 0, 0, 0, 0, 0])
      expect(tree.state()).toMatchObject({ deletePending: false, rootNodePath: [0, 0, 0, 0, 0, 0, 0], maxReplyNodeDepth: 2, unread_entries: [] })

      let details = shallow(tree.instance().renderDetails(discussion))
      let pop = details.find('[testID="discussion.popToLastDiscussionList"]')

      pop.simulate('press')
      expect(tree.state()).toMatchObject({ deletePending: false, rootNodePath: [0, 0, 0, 0, 0], maxReplyNodeDepth: 2, unread_entries: [] })

      pop.simulate('press')
      expect(tree.state()).toMatchObject({ deletePending: false, rootNodePath: [0, 0, 0], maxReplyNodeDepth: 2, unread_entries: [] })

      pop.simulate('press')
      expect(tree.state()).toMatchObject({ deletePending: false, rootNodePath: [], maxReplyNodeDepth: 2, unread_entries: [] })
    })

    it('does not show require_initial_post message on render', () => {
      const details = renderDetails({
        ...props,
        requireInitialPost: false,
      })
      expect(details.find('[testID="discussions.details.require_initial_post.message"]')).toHaveLength(0)
    })

    it('shows require_initial_post message', () => {
      const details = renderDetails({
        ...props,
        initialPostRequired: true,
      })
      expect(details.find('[testID="discussions.details.require_initial_post.message"]')).toHaveLength(1)
    })
  })

  describe('reply', () => {
    beforeEach(() => {
      props = {
        ...props,
        discussion: template.discussion({
          participants: [template.userDisplay()],
          replies: [template.discussionReply({
            myPath: [0],
          })],
        }),
      }
    })

    function renderReply (props) {
      return shallow(new DiscussionDetails(props).renderReply({ item: props.discussion.replies[0], index: 0 }))
    }

    test('renders', () => {
      let reply = renderReply(props).find('Reply')
      let replyProps = reply.props()

      expect(replyProps.context).toEqual(props.context)
      expect(replyProps.contextID).toEqual(props.contextID)
      expect(replyProps.discussionID).toEqual(props.discussionID)
      expect(replyProps.reply).toEqual(props.discussion.replies[0])
      expect(replyProps.readState).toEqual(props.discussion.replies[0].readState)
      expect(replyProps.depth).toEqual(props.discussion.replies[0].depth)
      expect(replyProps.myPath).toEqual([0])
      expect(replyProps.participants).toEqual(props.discussion.participants)
      expect(replyProps.discussionLockedForUser).toEqual(props.discussion.locked_for_user)
      expect(replyProps.userCanReply).toEqual(props.permissions.post_to_forum)
      expect(replyProps.rating).toEqual(props.discussion.replies[0].rating)
      expect(replyProps.canRate).toEqual(props.canRate)
      expect(replyProps.showRating).toEqual(props.discussion.allow_rating)
      expect(replyProps.isAnnouncement).toEqual(props.isAnnouncement)
    })

    it('alerts to confirm delete reply', () => {
      Alert.alert = jest.fn()
      ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
      let tree = renderReply(props)
      let reply = tree.find('Reply')
      reply.prop('deleteDiscussionEntry')('1', '1', '1')
      expect(Alert.alert).toHaveBeenCalledWith(
        'Are you sure you want to delete this reply?',
        null,
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'OK', onPress: expect.any(Function) },
        ],
      )
    })

    it('deletes discussion reply', () => {
      ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
      Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
      let tree = renderReply(props)
      let reply = tree.find('Reply')
      reply.prop('deleteDiscussionEntry')('1', '1', '1', [0, 1])
      expect(props.deleteDiscussionEntry).toHaveBeenCalledWith('1', '1', '1', [0, 1])
    })

    it('routes to discussion edit on entry reply', () => {
      let tree = renderReply({
        ...props,
        isAnnouncement: false,
        courseID: '1',
        discussion: template.discussion({
          id: '2',
          replies: [template.discussionReply({
            myPath: [0],
          })],
        }),
      })
      let reply = tree.find('Reply')
      reply.prop('replyToEntry')('3', [1, 0])

      expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/1/entries/3/replies', { modal: true, disableSwipeDownToDismissModal: true }, {
        'entryID': '3',
        'indexPath': [1, 0],
        lastReplyAt: props.discussion.last_reply_at,
        permissions: props.discussion.permissions,
      })
    })

    it('presses more replies', () => {
      let aaaaaaaaa = template.discussionReply({ id: '9' })
      let aaaaaaaa = template.discussionReply({ id: '8', replies: [aaaaaaaaa] })
      let aaaaaaa = template.discussionReply({ id: '7', replies: [aaaaaaaa] })
      let aaaaaa = template.discussionReply({ id: '6', replies: [aaaaaaa] })
      let aaaaa = template.discussionReply({ id: '5', replies: [aaaaaa] })
      let aaaa = template.discussionReply({ id: '4', replies: [aaaaa] })
      let aaa = template.discussionReply({ id: '3', replies: [aaaa] })
      let aa = template.discussionReply({ id: '2', replies: [aaa] })
      let a = template.discussionReply({ id: '1', replies: [aa] })
      let discussion = template.discussion({ replies: [a] })

      let tree = shallow(<DiscussionDetails {...props} discussion={discussion} />)
      let reply = shallow(tree.instance().renderReply({ item: discussion.replies[0], index: 0 })).find('Reply')
      reply.simulate('pressMoreReplies', [0, 0, 0])
      expect(tree.state('rootNodePath')).toEqual([0, 0, 0])
    })
  })

  it('calls refreshSingleDiscussion on unmount to update unread count', () => {
    let tree = shallow(<DiscussionDetails {...props} />)
    tree.unmount()
    expect(props.refreshSingleDiscussion).toHaveBeenCalledWith(props.context, props.contextID, props.discussionID)
  })

  it('does not call refreshSingleDiscussion on unmount if no discussion (was deleted)', () => {
    let tree = shallow(<DiscussionDetails {...props} discussion={null} />)
    tree.unmount()
    expect(props.refreshSingleDiscussion).not.toHaveBeenCalledWith()
  })

  it('routes to the right place when submissions is tapped', () => {
    let tree = shallow(<DiscussionDetails {...props} assignment={template.assignment({ id: '1', course_id: props.contextID })} />)
    tree.instance().viewAllSubmissions()
    expect(props.navigator.show).toHaveBeenCalledWith(
      `/courses/${props.contextID}/assignments/1/submissions`
    )
  })

  it('pops after delete without refresh', () => {
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(2))
    Alert.alert = jest.fn((title, message, buttons) => buttons[1].onPress())
    let deleteDiscussion = jest.fn()
    let tree = shallow(<DiscussionDetails {...props} deleteDiscussion={deleteDiscussion} />)
    let kabob = tree.find('Screen').prop('rightBarButtons')[0]
    kabob.action()
    expect(deleteDiscussion).toHaveBeenCalledWith(props.context, props.contextID, props.discussionID)

    tree.setProps({
      ...props,
      pending: false,
      discussion: null,
    })
    expect(props.navigator.pop).toHaveBeenCalled()
    expect(props.refreshSingleDiscussion).not.toHaveBeenCalled()
  })

  it('alerts error', () => {
    const screen = shallow(<DiscussionDetails {...props} />)
    screen.setProps({ error: 'ERROR!' })
    expect(alertError).toHaveBeenCalledWith('ERROR!')
  })

  it('informs app store review of navigation', () => {
    const tree = shallow(<DiscussionDetails {...props} />)
    expect(NativeModules.AppStoreReview.handleNavigateToAssignment)
      .toHaveBeenCalled()
    tree.unmount()
    expect(NativeModules.AppStoreReview.handleNavigateFromAssignment)
      .toHaveBeenCalled()
  })

  it('replaces with correct group discussion when received new props', () => {
    app.setCurrentApp('student')
    props.discussion = null
    props.context = 'courses'
    props.navigator = template.navigator({ replace: jest.fn() })
    props.groups = { '4': { group: template.group(), color: '' } }
    const screen = shallow(<DiscussionDetails {...props} />)

    const discussion = template.discussion({
      id: '1',
      group_category_id: '3',
      group_topic_children: [
        {
          id: '49',
          group_id: '4',
        },
      ],
    })
    screen.setProps({ discussion })

    expect(props.navigator.replace).toHaveBeenCalledWith('/groups/4/discussion_topics/49')
  })

  it('replaces with correct group discussion when created', () => {
    app.setCurrentApp('student')
    const discussion = template.discussion({
      id: '1',
      group_category_id: '3',
      group_topic_children: [
        {
          id: '49',
          group_id: '4',
        },
      ],
    })
    props.discussion = discussion
    props.context = 'courses'
    props.navigator = template.navigator({ replace: jest.fn() })
    props.groups = { '4': { group: template.group(), color: '' } }
    shallow(<DiscussionDetails {...props} />)

    expect(props.navigator.replace).toHaveBeenCalledWith('/groups/4/discussion_topics/49')
  })

  it('marks discussion as viewed', () => {
    app.setCurrentApp('student')
    const spy = jest.fn()
    NativeModules.ModuleItemsProgress.viewedDiscussion = spy
    props.context = 'courses'
    props.contextID = '1'
    props.discussionID = '2'
    shallow(<DiscussionDetails {...props} />)
    expect(spy).toHaveBeenCalledWith('1', '2')
  })

  it('wont replace with group discussion more than once', () => {
    app.setCurrentApp('student')
    props.discussion = null
    props.context = 'courses'
    props.navigator = template.navigator({ replace: jest.fn() })
    props.groups = { '4': { group: template.group(), color: '' } }
    const screen = shallow(<DiscussionDetails {...props} />)

    const discussion = template.discussion({
      id: '1',
      group_category_id: '3',
      group_topic_children: [
        {
          id: '49',
          group_id: '4',
        },
      ],
    })
    screen.setProps({ discussion })
    screen.setProps({ discussion })
    expect(props.navigator.replace).toHaveBeenCalledTimes(1)
  })

  it('marks topic as read', () => {
    props.markTopicAsRead = jest.fn()
    props.context = 'courses'
    props.contextID = '1'
    props.discussionID = '2'
    shallow(<DiscussionDetails {...props} />)
    expect(props.markTopicAsRead).toHaveBeenCalledWith('courses', '1', '2')
  })
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
            permissions: { post_to_forum: true },
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
      entryRatings: { '4': 1 },
      permissions: { post_to_forum: true },
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

  it('handles isAnnouncement appState prop', () => {
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
            isAnnouncement: true,
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
      permissions: { post_to_forum: true },
    }

    props.allow_rating = false
    expect(shouldRefresh(props)).toBeFalsy()

    props.discussion.allow_rating = true
    expect(shouldRefresh(props)).toBeTruthy()
  })
})
