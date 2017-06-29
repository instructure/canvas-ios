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

    state.didSnapTo(0)
    expect(state.currentSnap).toEqual(0)
    expect(mockValue.mock).toHaveBeenCalledWith(0)
    expect(drawer.snapTo).toHaveBeenCalledWith(0, false)
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

