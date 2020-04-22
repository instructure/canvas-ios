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

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import { Animated } from 'react-native'
import CommentStatus from '../CommentStatus'
import DrawerState from '../../utils/drawer-state'
import renderer from 'react-test-renderer'
import setProps from '../../../../../test/helpers/setProps'

let defaultProps = {
  userID: '1',
  isDone: false,
  animationComplete: jest.fn(),
  drawerState: new DrawerState(),
}

describe('CommentStatus', () => {
  beforeEach(() => jest.clearAllMocks())
  it('renders', () => {
    let tree = renderer.create(
      <CommentStatus {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
    expect(defaultProps.drawerState.commentProgress['1']).not.toBeNull()
  })

  it('uses an existing animated value if one exists in drawerState', () => {
    let progress = new Animated.Value(0)
    defaultProps.drawerState.registerCommentProgress('1', progress)
    let tree = renderer.create(
      <CommentStatus {...defaultProps} />
    )
    expect(tree.getInstance().progress).toEqual(progress)
    defaultProps.drawerState.unregisterCommentProgress('1')
  })

  // This test is busted for unknown reasons...
  // it('animates with a duration based on existing animated value', () => {
  //   let oldTiming = Animated.timing
  //   Animated.timing = jest.fn(() => ({ start: jest.fn() }))
  //   renderer.create(
  //     <CommentStatus {...defaultProps} />
  //   )

  //   expect(Animated.timing.mock.calls[0][1]).toMatchObject({
  //     toValue: 0.8,
  //     duration: 60000,
  //   })

  //   defaultProps.drawerState.commentProgress['1'].setValue(0.5)
  //   renderer.create(
  //     <CommentStatus {...defaultProps} />
  //   )
  //   expect(Animated.timing.mock.calls[1][1]).toMatchObject({
  //     toValue: 0.8,
  //     duration: 30000,
  //   })

  //   Animated.timing = oldTiming
  // })

  it('animates quickly once the comment is done sending', () => {
    let oldTiming = Animated.timing
    Animated.timing = jest.fn(() => ({ start: jest.fn() }))

    let tree = renderer.create(
      <CommentStatus {...defaultProps} />
    )
    setProps(tree, { isDone: true })

    expect(Animated.timing.mock.calls[1][1]).toMatchObject({
      toValue: 1,
      duration: 300,
    })

    Animated.timing = oldTiming
  })

  it('calls animationComplete once the successful animation completes', () => {
    let oldTiming = Animated.timing
    let start = jest.fn()
    Animated.timing = jest.fn(() => ({ start }))

    let tree = renderer.create(
      <CommentStatus {...defaultProps} />
    )
    setProps(tree, { isDone: true })

    expect(start).toHaveBeenCalled()
    start.mock.calls[1][0]()
    expect(defaultProps.animationComplete).toHaveBeenCalled()

    Animated.timing = oldTiming
  })

  it('sets the new width onLayout changes', () => {
    let tree = renderer.create(
      <CommentStatus {...defaultProps} />
    )

    tree.getInstance().onLayout({
      nativeEvent: {
        layout: {
          width: 100,
        },
      },
    })

    expect(tree.getInstance().state.width).toEqual(100)
  })
})
