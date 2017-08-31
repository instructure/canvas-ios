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

import 'react-native'
import React from 'react'
import ToolTip from '../ToolTip'
import renderer from 'react-test-renderer'

jest.mock('Animated', () => {
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
