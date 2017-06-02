/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import DiscussionReplies, { type Props } from '../DiscussionReplies'

jest.mock('Button', () => 'Button').mock('TouchableHighlight', () => 'TouchableHighlight').mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/users'),
}

jest.mock('WebView', () => 'WebView')

describe('DiscussionReplies', () => {
  let props
  let user = template.userDisplay()
  beforeEach(() => {
    props = {
      replies: [template.discussionReply()],
      depth: 0,
      participants: { [user.id]: user },
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
