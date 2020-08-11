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

// @flow

import DrawerState from '../drawer-state'
import BottomDrawer from '../../../../common/components/BottomDrawer'
import { Animated } from 'react-native'

class MockAnimated extends Animated.Value {
  mock = jest.fn()
  setValue (v: number) {
    super.setValue(v)
    this.mock(v)
  }
}

describe('DrawerState', () => {
  const state = new DrawerState()
  state.currentSnap = 0

  const drawer = new BottomDrawer({
    drawerState: state,
  })

  beforeEach(() => {
    drawer.UNSAFE_componentWillMount()
  })

  it('registers drawers', () => {
    expect(state.drawers.length).toEqual(1)
  })

  it('snaps registered drawers', () => {
    drawer.snapTo = jest.fn()
    const mockValue = new MockAnimated(0)
    state.deltaY = mockValue
    state.snapTo(2, false)
    state.deltaY.setValue(120)

    expect(drawer.snapTo).toHaveBeenCalledWith(2, false)
    expect(drawer.snapTo.mock.calls.length).toEqual(2)

    state.drawerDidSnap(drawer, 0)
    expect(state.currentSnap).toEqual(0)
    expect(mockValue.mock).toHaveBeenCalledWith(0)
    expect(drawer.snapTo).toHaveBeenCalledWith(2, false)
    expect(drawer.snapTo.mock.calls.length).toEqual(2)
  })

  it('unregisters drawers in componentWillUnmount', () => {
    drawer.componentWillUnmount()
    expect(state.drawers.length).toEqual(0)
  })

  it('registers comment progress', () => {
    state.registerCommentProgress('1', new Animated.Value(1234))
    expect(state.commentProgress['1']._value).toEqual(1234)
  })

  it('unregisters comment progress', () => {
    state.unregisterCommentProgress('1')
    expect(state.commentProgress['1']).toBeUndefined()
  })
})

