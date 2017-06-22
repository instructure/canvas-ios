/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import DiscussionReplies, { type Props } from '../DiscussionReplies'

jest.mock('Button', () => 'Button').mock('TouchableHighlight', () => 'TouchableHighlight').mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../__templates__/helm'),
}

jest.mock('WebView', () => 'WebView')

describe('DiscussionReplies', () => {
  let props
  let user = template.userDisplay()
  beforeEach(() => {
    props = {
      reply: template.discussionReply(),
      depth: 0,
      participants: { [user.id]: user },
      courseID: '1',
      discussionID: '1',
      deleteDiscussionEntry: jest.fn(),
      replyToEntry: jest.fn(),
      navigator: template.navigator(),
      pathIndex: 0,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: Props): any {
    return renderer.create(<DiscussionReplies {...props}/>)
  }
})
