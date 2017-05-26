/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import DiscussionsRow, { type Props } from '../DiscussionsRow'
import explore from '../../../../../test/helpers/explore'

jest.mock('Button', () => 'Button').mock('TouchableHighlight', () => 'TouchableHighlight').mock('TouchableOpacity', () => 'TouchableOpacity')

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
}

describe('DiscussionsRow', () => {
  let props
  beforeEach(() => {
    props = {
      discussion: template.discussion(),
      onPress: jest.fn(),
      index: 0,
      tintColor: '#fff',
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders published', () => {
    props.discussion.published = true
    testRender(props)
  })

  it('renders unpublished', () => {
    props.discussion.published = false
    testRender(props)
  })

  it('sends onPress', () => {
    const tree = render(props).toJSON()
    const row : any = explore(tree).selectByID('discussion-row-0')
    row.props.onPress()
    expect(props.onPress).toHaveBeenCalledWith(props.discussion)
  })

  it('renders without points possible', () => {
    if (props.discussion.assignment) {
      props.discussion.assignment.points_possible = null
    }
    testRender(props)
  })

  it('renders with points possible', () => {
    if (props.discussion.assignment) {
      props.discussion.assignment.points_possible = 12
    }
    testRender(props)
  })

  function testRender (props: Props) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: Props): any {
    return renderer.create(<DiscussionsRow {...props}/>)
  }
})
