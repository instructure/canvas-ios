//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

  it('should trigger UNSAFE_componentWillReceiveProps', () => {
    const UNSAFE_componentWillReceiveProps = jest.fn()
    component.getInstance().UNSAFE_componentWillReceiveProps = UNSAFE_componentWillReceiveProps

    setProps(component, { test: 'setProps' })
    expect(UNSAFE_componentWillReceiveProps).toHaveBeenCalledWith({ test: 'setProps' })
  })

  it('should set the props', () => {
    setProps(component, { test: 'setProps sets props' })
    expect(component.getInstance().props).toEqual({ test: 'setProps sets props' })
  })
})
