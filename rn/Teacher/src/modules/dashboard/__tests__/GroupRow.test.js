// @flow

import React from 'react'
import 'react-native'
import GroupRow from '../GroupRow'
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let props = {
  style: { margin: 8 },
  id: '1',
  color: 'blue',
  name: 'Study Group 3',
  contextName: 'Bio 101',
  term: 'Spring 2020',
  onPress: jest.fn(),
}

describe('GroupRow', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    const tree = renderer.create(
      <GroupRow {...props} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('renders without a term', () => {
    const tree = renderer.create(
      <GroupRow {...props} term={undefined} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls onPress with the group id when pressed', () => {
    const view = renderer.create(
      <GroupRow {...props} />
    )
    let group = explore(view.toJSON()).selectByID('group-row-1') || {}
    group.props.onPress()
    expect(props.onPress).toHaveBeenCalledWith('1')
  })
})
