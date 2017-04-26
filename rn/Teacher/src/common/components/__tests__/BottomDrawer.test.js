// @flow
import React from 'react'
import { Text } from 'react-native'
import { BottomDrawer } from '../BottomDrawer'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'

jest.mock('react-native-interactable', () => ({
  View: 'Interactable.View',
}))

describe('BottomDrawer', () => {
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
      <BottomDrawer setDrawerSnap={setDrawerSnap}>
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
      <BottomDrawer containerHeight={100} containerWidth={100}>
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
      <BottomDrawer>
        <Text>Yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    instance.drawer = { snapTo: jest.fn() }
    instance.open()
    expect(instance.drawer.snapTo).toHaveBeenCalledWith({ index: 1 })
  })

  it('doesnt call snapTo when the currentSnap is not 2', () => {
    let tree = renderer.create(
      <BottomDrawer>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    instance.setState({ currentSnap: 0 })
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
})
