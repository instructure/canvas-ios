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
    drawer.componentWillMount()
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

