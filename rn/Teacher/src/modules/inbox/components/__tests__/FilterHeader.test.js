/* @flow */
import 'react-native'
import React from 'react'
import FilterHeader from '../FilterHeader'
import explore from '../../../../../test/helpers/explore'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

it('renders correctly', () => {
  const tree = renderer.create(
    <FilterHeader selected={'all'} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

it('calls the passed in callback', () => {
  const callback = jest.fn()
  const tree = renderer.create(
    <FilterHeader selected={'all'} onFilterChange={callback}/>
  ).toJSON()
  const button = explore(tree).selectByID('inbox.filter-btn-unread') || {}
  button.props.onPress()
  expect(callback).toHaveBeenCalledWith('unread')
})
