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

import 'react-native'
import React from 'react'
import ToolTip from '../ToolTip'
import renderer from 'react-test-renderer'

jest.mock('react-native/Libraries/Animated/src/Animated', () => {
  const ActualAnimated = require.requireActual('Animated')
  return {
    ...ActualAnimated,
    timing: (value, config) => ({
      start: (callback) => {
        value.setValue(config.toValue)
        callback && callback()
      },
    }),
    spring: (value, config) => ({
      start: (callback) => {
        value.setValue(config.toValue)
        callback && callback()
      },
    }),
  }
})

test('ToolTip renders nothing until tooltip added', () => {
  let tree = renderer.create(
    <ToolTip />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('ToolTip renders something interesting when showToolTip is called', () => {
  let toolTip = renderer.create(
    <ToolTip />
  )

  toolTip.getInstance().showToolTip({ x: 5, y: 20 }, 'The quick brown fox...')
  toolTip.getInstance().setState({ toolTipLayoutWidth: 100 })
  let tree = toolTip.toJSON()
  expect(tree).toMatchSnapshot()
})

// Broken in rn 45.0
// test('toolTip hides on tap out', () => {
//   let toolTip = renderer.create(
//     <ToolTip />
//   )

//   const largeTip = 'The quick brown fox jumps over the lazy dog. I am the very model of a modern major general.'
//   toolTip.getInstance().showToolTip({ x: 5, y: 20 }, largeTip)
//   expect(toolTip.toJSON()).toMatchSnapshot()

//   toolTip.getInstance().dismissToolTip()
//   expect(toolTip.toJSON()).toMatchSnapshot()
// })

// Broken in rn 45.0
// test('toolTip is constrained to width of screen', () => {
//   let toolTip = renderer.create(
//     <ToolTip />
//   )

//   const largeTip = 'The quick brown fox jumps over the lazy dog. I am the very model of a modern major general.'
//   toolTip.getInstance().showToolTip({ x: 5, y: 20 }, largeTip)
//   toolTip.getInstance().onToolTipLayout({ nativeEvent: { layout: { width: 1024 } } })
//   expect(toolTip.toJSON()).toMatchSnapshot()
// })
