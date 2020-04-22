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
import React from 'react'
import { Text } from 'react-native'
import BottomDrawer from '../BottomDrawer'
import renderer from 'react-test-renderer'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'
import { SpeedGrader } from '../../../modules/speedgrader/SpeedGrader'

jest
  .mock('react-native-interactable', () => ({
    View: 'Interactable.View',
  }))
  .mock('react-native-button', () => 'Button')

describe('BottomDrawer', () => {
  beforeEach(() => jest.clearAllMocks())
  const state = SpeedGrader.drawerState

  it('renders any children', () => {
    let tree = renderer.create(
      <BottomDrawer currentSnap={2} drawerState={state}>
        <Text>Yo yo yo</Text>
      </BottomDrawer>
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('sets the new height and width state when props change', () => {
    let tree = renderer.create(
      <BottomDrawer containerHeight={200} containerWidth={100} currentSnap={2} drawerState={state}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    expect(instance.state.height).toEqual(200)
    expect(instance.state.width).toEqual(100)

    setProps(tree, { containerHeight: 240, containerWidth: 200 })
    instance = tree.getInstance()
    expect(instance.state.height).toEqual(240)
    expect(instance.state.width).toEqual(200)
  })

  it('calls snapTo when currentSnap is 2', () => {
    let tree = renderer.create(
      <BottomDrawer currentSnap={2} drawerState={state}>
        <Text>Yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    let snapTo = jest.fn()
    instance.drawer = { snapTo }
    instance.open()
    expect(snapTo).toHaveBeenCalledWith({ index: 1 })
  })

  it('doesnt call snapTo when the currentSnap is not 0', () => {
    state.currentSnap = 2
    let tree = renderer.create(
      <BottomDrawer drawerState={state}>
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
      <BottomDrawer drawerState={state}>
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
    state.currentSnap = 0
    let tree = renderer.create(
      <BottomDrawer drawerState={state}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    let instance = tree.getInstance()
    let button = explore(tree.toJSON()).selectByID('bottom-drawer.cycle') || {}
    let snapTo = jest.fn()
    instance.drawer = { snapTo }
    button.props.onPress()
    expect(snapTo).toHaveBeenLastCalledWith({ index: 1 })

    state.currentSnap = 1
    tree = renderer.create(
      <BottomDrawer drawerState={state}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    instance = tree.getInstance()
    button = explore(tree.toJSON()).selectByID('bottom-drawer.cycle') || {}
    snapTo = jest.fn()
    instance.drawer = { snapTo }
    button.props.onPress()
    expect(snapTo).toHaveBeenLastCalledWith({ index: 2 })

    state.currentSnap = 2
    tree = renderer.create(
      <BottomDrawer currentSnap={0} drawerState={state}>
        <Text>yo yo yo</Text>
      </BottomDrawer>
    )
    instance = tree.getInstance()
    button = explore(tree.toJSON()).selectByID('bottom-drawer.cycle') || {}
    snapTo = jest.fn()
    instance.drawer = { snapTo }
    button.props.onPress()
    expect(snapTo).toHaveBeenLastCalledWith({ index: 0 })
  })
})
