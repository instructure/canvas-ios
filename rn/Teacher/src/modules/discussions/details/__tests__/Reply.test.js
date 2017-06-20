/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import Reply, { type Props } from '../Reply'

jest.mock('Button', () => 'Button').mock('TouchableHighlight', () => 'TouchableHighlight').mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../__templates__/helm'),
}
jest.mock('WebView', () => 'WebView')

describe('DiscussionReplies', () => {
  let props
  beforeEach(() => {
    let reply = template.discussionReply()
    reply.replies = [template.discussionReply({ id: 2 })]
    let user = template.userDisplay()
    props = {
      reply: reply,
      depth: 0,
      participants: { [user.id]: user },
      navigator: template.navigator(),
    }
  })

  it('renders', () => {
    testRender(props)
  })

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: Props): any {
    return renderer.create(<Reply {...props}/>)
  }

  it('shows attachment', () => {
    props.reply = Object.assign(props.reply, { attachment: { } })
    let tree = render(props)

    tree.getInstance().showAttachment()

    expect(props.navigator.show).toHaveBeenCalledWith(
      '/attachment',
      { modal: true },
      { attachment: props.reply.attachment }
    )
  })
})
