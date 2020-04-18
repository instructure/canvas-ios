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
import 'react-native'
import renderer from 'react-test-renderer'
import VideoRecorder, { type Props } from '../VideoRecorder'
import explore from '../../../../test/helpers/explore'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('../Video', () => 'Video')

describe('VideoRecorder', () => {
  let props: Props
  beforeEach(() => {
    props = {
      onFinishedRecording: jest.fn(),
      onCancel: jest.fn(),
    }
  })

  it('renders ready', () => {
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders recording', () => {
    jest.useFakeTimers()
    const view = render(props)
    const btn: any = explore(view.toJSON()).selectByID('video-recorder.start-recording.btn')
    btn.props.onPress()
    jest.runTimersToTime(1000)
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders finished', () => {
    const createNodeMock = ({ type }) => {
      if (type === 'Camera') {
        return {
          recordAsync: jest.fn(() => ({ then: callback => callback({ uri: '/comment.mov' }) })),
          stopRecording: jest.fn(),
        }
      }
    }
    const view = render(props, { createNodeMock })
    const btn: any = explore(view.toJSON()).selectByID('video-recorder.start-recording.btn')
    btn.props.onPress()
    btn.props.onPress()
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders loading', () => {
    const view = render(props)
    const btn: any = explore(view.toJSON()).selectByID('video-recorder.start-recording.btn')
    btn.props.onPress()
    btn.props.onPress()
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('sends recording', () => {
    const spy = jest.fn()
    props.onFinishedRecording = spy
    const createNodeMock = ({ type }) => {
      if (type === 'Camera') {
        return {
          recordAsync: jest.fn(() => ({ then: callback => callback({ uri: '/comment.mov' }) })),
          stopRecording: jest.fn(),
        }
      }
    }
    const view = render(props, { createNodeMock })
    const btn: any = explore(view.toJSON()).selectByID('video-recorder.start-recording.btn')
    btn.props.onPress()
    btn.props.onPress()
    const send: any = explore(view.toJSON()).selectByID('video-recorder.send.btn')
    send.props.onPress()
    expect(spy).toHaveBeenCalledWith({
      fileName: 'Video Recording',
      filePath: '/comment.mov',
    })
  })

  it('sends cancel', () => {
    const spy = jest.fn()
    props.onCancel = spy
    const view = render(props)
    const cancel: any = explore(view.toJSON()).selectByID('video-recorder.cancel.btn')
    cancel.props.onPress()
    expect(spy).toHaveBeenCalled()
  })

  it('renders reset', () => {
    const createNodeMock = ({ type }) => {
      if (type === 'Camera') {
        return {
          recordAsync: jest.fn(() => ({ then: callback => callback({ uri: '/comment.mov' }) })),
          stopRecording: jest.fn(),
        }
      }
    }
    const view = render(props, { createNodeMock })
    const btn: any = explore(view.toJSON()).selectByID('video-recorder.start-recording.btn')
    btn.props.onPress()
    btn.props.onPress()
    const reset: any = explore(view.toJSON()).selectByID('video-recorder.reset.btn')
    reset.props.onPress()
    expect(view.toJSON()).toMatchSnapshot()
  })

  function render (props: Props, options: ?any): any {
    const createNodeMock = ({ type }) => {
      if (type === 'Camera') {
        return {
          recordAsync: jest.fn(() => new Promise(() => {})),
          stopRecording: jest.fn(),
        }
      }
    }
    return renderer.create(<VideoRecorder {...props} />, options || { createNodeMock })
  }
})
