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

import { shallow } from 'enzyme'
import React from 'react'
import { ActionSheetIOS } from 'react-native'
import Reply, { type Props } from '../Reply'
import httpClient from '../../../../canvas-api/httpClient'
import * as template from '../../../../__templates__'

jest.mock('ActionSheetIOS', () => ({
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
    }
    jest.clearAllMocks()
  })

  it('renders', () => {
    expect(shallow(<Reply {...props}/>)).toMatchSnapshot()
  })

  it('renders deleted', () => {
    props.reply.deleted = true
    let tree = shallow(<Reply {...props} />)
    let webview = tree.find('RichContent')
    expect(webview.props().html.includes('Deleted this reply.')).toEqual(true)
  })

  it('renders with no user', () => {
    props.reply.user_id = ''
    props.reply.editor_id = ''
    let tree = shallow(<Reply {...props} />)
    expect(tree.find('Avatar').props().userName).toEqual('?')
  })

  it('renders with closed discussion as student', () => {
    props.discussionLockedForUser = true
    let tree = shallow(<Reply {...props} />)

    expect(tree.find('[testID="discussions.reply-btn"]').length).toEqual(0)
    expect(tree.find('[testID="discussions.edit-btn"]').length).toEqual(0)
    expect(tree.find('[testID="discussion.reply.rate-btn"]').length).toEqual(0)
  })

  it('renders likes even if closed as student', () => {
    props.discussionLockedForUser = true
    props.showRating = true
    props.canRate = true
    let tree = shallow(<Reply {...props} />)

    expect(tree.find('[testID="discussion.reply.rate-btn"]').length).toEqual(1)
  })

  it('navigates to the context card when an avatar is pressed', () => {
    let tree = shallow(<Reply {...props} />)
    let avatar = tree.find('[testID="reply.avatar"]')
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
    let replyButton = tree.find('[testID="discussion.more-replies"]')
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
    expect(tree.find('[testID="discussion.more-replies"]').length).toEqual(1)
  })

  it('edit action sheet calls delete', () => {
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((_, cb) => cb(1))
    let tree = shallow(<Reply {...props} />)
    let edit = tree.find('[testID="discussion.edit-btn"]')
    edit.simulate('press')

    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(props.deleteDiscussionEntry).toHaveBeenCalledWith('courses', '1', '1', '1', [0])
  })

  it('edit action sheet calls cancel', () => {
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((_, cb) => cb(2))
    let tree = shallow(<Reply {...props} />)
    let edit = tree.find('[testID="discussion.edit-btn"]')
    edit.simulate('press')

    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(props.deleteDiscussionEntry).not.toHaveBeenCalled()
    expect(props.navigator.show).not.toHaveBeenCalled()
  })

  it('edit action sheet calls edit', () => {
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((_, cb) => cb(0))
    let tree = shallow(<Reply {...props} />)
    let edit = tree.find('[testID="discussion.edit-btn"]')
    edit.simulate('press')

    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/discussion_topics/1/reply', { modal: true }, { message: props.reply.message, entryID: props.reply.id, isEdit: true, indexPath: props.myPath })
  })

  it('reply to entry', () => {
    let tree = shallow(<Reply {...props} />)
    let reply = tree.find('[testID="discussion.reply-btn"]')
    reply.simulate('press')

    expect(props.replyToEntry).toHaveBeenCalledWith('1', [0])
  })

  it('shows attachment', () => {
    props.reply = Object.assign(props.reply, { attachment: { } })
    let tree = shallow(<Reply {...props}/>)
    let showAttachment = tree.find(`[testID="discussion-reply.${props.reply.id}.attachment"]`)
    showAttachment.simulate('press')

    expect(props.navigator.show).toHaveBeenCalledWith(
      '/attachment',
      { modal: true },
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
      expect(tree.find('[testID="discussion.reply.rating-count"]').length).toEqual(1)
    })

    it('renders user rating', () => {
      props.showRating = true
      props.canRate = true
      props.rating = 1
      let tree = shallow(<Reply {...props} />)
      let rating = tree.find('[testID="discussion.reply.rating-count"]')
      expect(rating.props().children).toEqual(['(', '2', ')'])
    })

    it('renders rating when user cant rate', () => {
      props.showRating = true
      props.canRate = false
      let tree = shallow(<Reply {...props} />)
      let rating = tree.find('[testID="discussion.reply.rating-count"]')
      expect(rating.props().children).toEqual(['(', '2 likes', ')'])
    })

    it('renders rating after user rates for first time', () => {
      props.showRating = true
      props.canRate = true
      props.rating = null
      const view = shallow(<Reply {...props }/>)
      const rateBtn = view.find('[testID="discussion.reply.rate-btn"]')
      rateBtn.simulate('Press')
      view.update()
      expect(view).toMatchSnapshot()
    })

    it('renders rating after user updates rating', () => {
      props.showRating = true
      props.canRate = true
      props.rating = 1
      const view = shallow(<Reply {...props }/>)
      const rateBtn = view.find('[testID="discussion.reply.rate-btn"]')
      rateBtn.simulate('Press')
      view.update()
      expect(view).toMatchSnapshot()
    })

    it('fixes unverified urls', async () => {
      const evaluateJavaScript = jest.fn()
      const url = 'https://canvas.instructure.com/files/1/preview?verifier=1234'
      const promise = Promise.resolve({ data: template.file({ url }) })
      httpClient().get = jest.fn(() => promise)
      let imageReply = template.discussionReply({ id: '1', message: `<img src="${url}" />` })

      const screen = shallow(<Reply {...props} reply={imageReply} />)
      const webView = screen.find('CanvasWebView')
      webView.getElement().ref({ evaluateJavaScript })

      webView.prop('onFinishedLoading')()
      expect(evaluateJavaScript).toHaveBeenCalled()
      expect(evaluateJavaScript.mock.calls).toMatchSnapshot()

      evaluateJavaScript.mockClear()

      const message = { type: 'BROKEN_IMAGES', data: ['api-url'] }
      webView.prop('onMessage')({ body: JSON.stringify(message) })
      await promise
      expect(evaluateJavaScript).toHaveBeenCalled()
      expect(evaluateJavaScript.mock.calls).toMatchSnapshot()
    })
  })
})
