/* @flow */

import React from 'react'
import renderer from 'react-test-renderer'
import { View } from 'react-native'

import setProps from '../setProps'

describe('setProps', () => {
  let component: any
  beforeEach(() => {
    component = renderer.create(
      <View></View>
    )
  })

  it('should trigger componentWillReceiveProps', () => {
    const componentWillReceiveProps = jest.fn()
    component.getInstance().componentWillReceiveProps = componentWillReceiveProps

    setProps(component, { test: 'setProps' })
    expect(componentWillReceiveProps).toHaveBeenCalledWith({ test: 'setProps' })
  })

  it('should set the props', () => {
    setProps(component, { test: 'setProps sets props' })
    expect(component.getInstance().props).toEqual({ test: 'setProps sets props' })
  })
})
