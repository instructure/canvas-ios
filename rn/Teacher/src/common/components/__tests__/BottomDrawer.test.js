// @flow
import React from 'react'
import { Text } from 'react-native'
import { BottomDrawer } from '../BottomDrawer'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'

jest
  .mock('react-native-interactable', () => ({
    View: 'Interactable.View',
  }))
  .mock('react-native-button', () => 'Button')

describe('BottomDrawer', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders any children', () => {
    let tree = renderer.create(
      <BottomDrawer currentSnap={2}>
        <Text>Yo yo yo</Text>
      </BottomDrawer>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('sets the new currentSnap when onSnap is called', () => {
    const setDrawerSnap = jest.fn()
    let tree = renderer.create(
      <BottomDrawer setDrawerSnap={setDrawerSnap} currentSnap={2}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    instance.onSnap({
      nativeEvent: {
        index: 1,
      },
    })
    expect(setDrawerSnap).toHaveBeenCalledWith(1)
  })

  it('sets the new height and width state when props change', () => {
    let tree = renderer.create(
      <BottomDrawer containerHeight={100} containerWidth={100} currentSnap={2}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    expect(instance.state.height).toEqual(100)
    expect(instance.state.width).toEqual(100)

    setProps(tree, { containerHeight: 200, containerWidth: 200 })
    instance = tree.getInstance()
    expect(instance.state.height).toEqual(200)
    expect(instance.state.width).toEqual(200)
  })

  it('calls snapTo when currentSnap is 2', () => {
    let tree = renderer.create(
      <BottomDrawer currentSnap={2}>
        <Text>Yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    let snapTo = jest.fn()
    instance.drawer = { snapTo }
    instance.open()
    expect(snapTo).toHaveBeenCalledWith({ index: 1 })
  })

  it('doesnt call snapTo when the currentSnap is not 2', () => {
    let tree = renderer.create(
      <BottomDrawer currentSnap={1}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    instance.drawer = { snapTo: jest.fn() }
    instance.open()
    expect(instance.drawer.snapTo).not.toHaveBeenCalled()
  })

  it('returns 3 snap points from getSnapPoints', () => {
    let tree = renderer.create(
      <BottomDrawer>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    let snapPoints = instance.getSnapPoints()
    expect(snapPoints[0].y).toBeLessThan(snapPoints[1].y)
    expect(snapPoints[1].y).toBeLessThan(snapPoints[2].y)
    expect(snapPoints.length).toEqual(3)
  })

  // because we setState after a cycle, and the drawer is a ref
  // the drawer attribute on the instance gets wiped out after every
  // call to cycle so we are just going to do it with 3 different trees
  it('cycles through snaps when the handle button is pressed', () => {
    let tree = renderer.create(
      <BottomDrawer currentSnap={2}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    let button = explore(tree.toJSON()).selectByID('bottom-drawer.cycle') || {}
    let snapTo = jest.fn()
    instance.drawer = { snapTo }
    button.props.onPress()
    expect(snapTo).toHaveBeenLastCalledWith({ index: 1 })

    tree = renderer.create(
      <BottomDrawer currentSnap={1}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    instance = tree.getInstance()
    button = explore(tree.toJSON()).selectByID('bottom-drawer.cycle') || {}
    snapTo = jest.fn()
    instance.drawer = { snapTo }
    button.props.onPress()
    expect(snapTo).toHaveBeenLastCalledWith({ index: 0 })

    tree = renderer.create(
      <BottomDrawer currentSnap={0}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    instance = tree.getInstance()
    button = explore(tree.toJSON()).selectByID('bottom-drawer.cycle') || {}
    snapTo = jest.fn()
    instance.drawer = { snapTo }
    button.props.onPress()
    expect(snapTo).toHaveBeenLastCalledWith({ index: 2 })
  })
})
