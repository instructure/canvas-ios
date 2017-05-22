/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import RowWithTextInput from '../RowWithTextInput'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')

describe('RowWithTextInput', () => {
  it('renders', () => {
    const tree = renderer.create(
      <RowWithTextInput />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('sends text changes', () => {
    const onChangeText = jest.fn()
    const tree = renderer.create(
      <RowWithTextInput
        onChangeText={onChangeText}
        identifier='test'
      />
    ).toJSON()
    const input: any = explore(tree).selectByID('test')
    input.props.onChangeText('changed')
    expect(onChangeText).toHaveBeenCalledWith('changed', 'test')
  })

  it('sets default value', () => {
    const tree = renderer.create(
      <RowWithTextInput
        identifier='test-default-value'
        defaultValue='test default value'
      />
    ).toJSON()
    const input: any = explore(tree).selectByID('test-default-value')
    expect(input.props.defaultValue).toEqual('test default value')
  })

  it('renders with a title', () => {
    expect(
      renderer.create(
        <RowWithTextInput title='Title' />
      ).toJSON()
    ).toMatchSnapshot()
  })
})
