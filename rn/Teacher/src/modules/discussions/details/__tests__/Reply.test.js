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

/* @flow */

import { shallow } from 'enzyme'
import React from 'react'
import { ActionSheetIOS } from 'react-native'
import Reply, { type Props } from '../Reply'
import * as template from '../../../../__templates__'

jest.mock('react-native/Libraries/ActionSheetIOS/ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))

describe('DiscussionReplies', () => {
  let props: Props
  beforeEach(() => {
    let reply = template.discussionReply({ id: '1' })
    reply.replies = [template.discussionReply({ id: 2 })]
    let user = template.userDisplay()
    props = {
      reply: reply,
      depth: 0,
      readState: 'read',
      participants: { [user.id]: user },
      context: 'courses',
      contextID: '1',
      discussionID: '1',
      entryID: '1',
      deleteDiscussionEntry: jest.fn(),
      replyToEntry: jest.fn(),
      myPath: [0],
      navigator: template.navigator(),
      onPressMoreReplies: jest.fn(),
      maxReplyNodeDepth: 2,
      discussionLockedForUser: false,
      rating: null,
      showRating: false,
      canRate: false,
      rateEntry: jest.fn(),
      isLastReply: false,
      isAnnouncement: false,
      userCanReply: true,
    }
    jest.clearAllMocks()
  })

  it('renders', () => {
    let tree = shallow(<Reply {...props} />)
    expect(tree.find(`[testID="discussion.reply.${props.reply.id}.reply-btn"]`).exists()).toBe(true)
  })

  it('renders without the reply button when the user cant reply', () => {
    let tree = shallow(<Reply {...props} userCanReply={false} />)
    expect(tree.find(`[testID="discussion.reply.${props.reply.id}.reply-btn"]`).exists()).toBe(false)
  })

  it('renders deleted', () => {
    props.reply.deleted = true
    let tree = shallow(<Reply {...props} />)
    let webview = tree.find('CanvasWebView')
    expect(webview.props().html.includes('Deleted this reply.')).toEqual(true)
  })

  it('does not show attachments when deleted', () => {
    props.reply.deleted = true
    props.reply.attachment = {}
    let tree = shallow(<Reply {...props} />)
    expect(tree.find(`[testID="discussion.reply.${props.reply.id}.attachment"]`).length).toEqual(0)
  })

  it('renders with no user', () => {
    props.reply.user_id = ''
    props.reply.editor_id = ''
    let tree = shallow(<Reply {...props} />)
    expect(tree.find('Avatar').props().userName).toEqual('?')
  })

  it('renders user display name', () => {
    let user = template.userDisplay({ display_name: 'Eve' })
    props.participants[props.reply.user_id] = user
    let tree = shallow(<Reply {...props} />)
    expect(tree.find('[testID="DiscussionReply.userName"]').prop('children')).toEqual('Eve')

    user.pronouns = 'She/Her'
    props.participants[props.reply.user_id] = user
    tree = shallow(<Reply {...props} />)
    expect(tree.find('[testID="DiscussionReply.userName"]').prop('children')).toEqual('Eve (She/Her)')
  })

  it('renders with closed discussion as student', () => {
    props.discussionLockedForUser = true
    let tree = shallow(<Reply {...props} />)

    expect(tree.find(`[testID="discussion.reply.${props.reply.id}.reply-btn"]`).length).toEqual(0)
    expect(tree.find(`[testID="discussion.reply.${props.reply.id}.edit-btn"]`).length).toEqual(0)
    expect(tree.find(`[testID="discussion.reply.${props.reply.id}.rate-btn"]`).length).toEqual(0)
  })

  it('renders likes even if closed as student', () => {
    props.discussionLockedForUser = true
    props.showRating = true
    props.canRate = true
    let tree = shallow(<Reply {...props} />)

    let rate = tree.find(`[testID="discussion.reply.${props.reply.id}.rate-btn"]`)
    expect(rate.exists()).toBe(true)
    expect(rate.prop('accessibilityStates')).toEqual([])
  })

  it('renders like accessibility state', () => {
    props.rating = 1
    props.showRating = true
    props.canRate = true
    let tree = shallow(<Reply {...props} />)

    let rate = tree.find(`[testID="discussion.reply.${props.reply.id}.rate-btn"]`)
    expect(rate.exists()).toBe(true)
    expect(rate.prop('accessibilityStates')).toEqual([ 'selected' ])
  })

  it('navigates to the context card when an avatar is pressed', () => {
    let tree = shallow(<Reply {...props} />)
    let avatar = tree.find(`[testID="discussion.reply.${props.reply.id}.avatar"]`)
    avatar.simulate('press')
    expect(props.navigator.show).toHaveBeenCalledWith(
      `/courses/1/users/1`,
      { modal: true },
    )
  })

  it('actionMore', () => {
    props.depth = 2
    props.reply.replies = [template.discussionReply({ id: 2 }), template.discussionReply({ id: 3 }), template.discussionReply({ id: 4 })]
    let tree = shallow(<Reply {...props} />)
    let replyButton = tree.find(`[testID="discussion.reply.${props.reply.id}.more-replies"]`)
    replyButton.simulate('press')
    expect(props.onPressMoreReplies).toHaveBeenCalledWith([0])
  })

  it('renders more button with some deleted replies', () => {
    let a = template.discussionReply({ id: '2' })
    let b = template.discussionReply({ id: '3' })
    let c = template.discussionReply({ id: '4', deleted: true })

    let reply = template.discussionReply({ id: '1', replies: [a, b, c] })
    props.reply = reply
    props.depth = 2
    let tree = shallow(<Reply {...props} />)
    expect(tree.find(`[testID="discussion.reply.${props.reply.id}.more-replies"]`).length).toEqual(1)
  })

  it('edit action sheet calls delete', () => {
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((_, cb) => cb(2))
    let tree = shallow(<Reply {...props} />)
    let edit = tree.find(`[testID="Reply.${props.reply.id}.moreButton"]`)
    edit.simulate('press')

    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(props.deleteDiscussionEntry).toHaveBeenCalledWith('courses', '1', '1', '1', [0])
  })

  it('edit action sheet calls cancel', () => {
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((_, cb) => cb(3))
    let tree = shallow(<Reply {...props} />)
    let edit = tree.find(`[testID="Reply.${props.reply.id}.moreButton"]`)
    edit.simulate('press')

    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(props.deleteDiscussionEntry).not.toHaveBeenCalled()
    expect(props.navigator.show).not.toHaveBeenCalled()
  })

  it('edit action sheet calls edit', () => {
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((_, cb) => cb(1))
    let tree = shallow(<Reply {...props} />)
    let edit = tree.find(`[testID="Reply.${props.reply.id}.moreButton"]`)
    edit.simulate('press')

    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/1/reply', { modal: true }, { message: props.reply.message, entryID: props.reply.id, isEdit: true, indexPath: props.myPath })
  })

  it('edit action sheet marks unread', () => {
    let spy = jest.fn()
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((_, cb) => cb(0))
    let tree = shallow(<Reply {...props} onMarkUnread={spy} />)
    let edit = tree.find(`[testID="Reply.${props.reply.id}.moreButton"]`)
    edit.simulate('press')
    expect(spy).toHaveBeenCalledWith('1')
  })

  it('edit action sheet marks as read', () => {
    let spy = jest.fn()
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((_, cb) => cb(0))
    let tree = shallow(<Reply {...props} markEntryAsRead={spy} readState='unread' />)
    let edit = tree.find(`[testID="Reply.${props.reply.id}.moreButton"]`)
    edit.simulate('press')
    expect(spy).toHaveBeenCalledWith('courses', '1', '1', '1')
  })

  it('reply to entry', () => {
    let tree = shallow(<Reply {...props} />)
    let reply = tree.find(`[testID="discussion.reply.${props.reply.id}.reply-btn"]`)
    reply.simulate('press')

    expect(props.replyToEntry).toHaveBeenCalledWith('1', [0])
  })

  it('shows attachment', () => {
    props.reply = Object.assign(props.reply, { attachment: { } })
    let tree = shallow(<Reply {...props}/>)
    let showAttachment = tree.find(`[testID="discussion.reply.${props.reply.id}.attachment"]`)
    showAttachment.simulate('press')

    expect(props.navigator.show).toHaveBeenCalledWith(
      '/attachment',
      { modal: true, disableSwipeDownToDismissModal: true },
      { attachment: props.reply.attachment }
    )
  })

  describe('ratings', () => {
    beforeEach(() => {
      props.reply = template.discussionReply({ id: '1', rating_sum: 2 })
    })

    it('renders rating', () => {
      props.showRating = true
      props.canRate = true
      let tree = shallow(<Reply {...props} />)
      expect(tree.find(`[testID="discussion.reply.${props.reply.id}.rating-count"]`).length).toEqual(1)
    })

    it('renders user rating', () => {
      props.showRating = true
      props.canRate = true
      props.rating = 1
      let tree = shallow(<Reply {...props} />)
      let rating = tree.find(`[testID="discussion.reply.${props.reply.id}.rating-count"]`)
      expect(rating.props().children).toEqual(['(', '2', ')'])
    })

    it('renders rating when user cant rate', () => {
      props.showRating = true
      props.canRate = false
      let tree = shallow(<Reply {...props} />)
      let rating = tree.find(`[testID="discussion.reply.${props.reply.id}.rating-count"]`)
      expect(rating.props().children).toEqual(['(', '2 likes', ')'])
    })

    it('calls rateEntry when the button is pushed', () => {
      props.showRating = true
      props.canRate = true
      props.rating = null
      const view = shallow(<Reply {...props }/>)
      const rateBtn = view.find(`[testID="discussion.reply.${props.reply.id}.rate-btn"]`)
      rateBtn.simulate('Press')
      expect(props.rateEntry).toHaveBeenCalledWith(props.context, props.contextID, props.discussionID, props.reply.id, 1, [0])
    })
  })
})
