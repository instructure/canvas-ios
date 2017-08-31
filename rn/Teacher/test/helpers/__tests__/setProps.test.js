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
