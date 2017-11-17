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

/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'
import VideoRecorder, { type Props } from '../VideoRecorder'
import explore from '../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
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
          capture: jest.fn(() => ({ then: callback => callback({ path: '/comment.mov' }) })),
          stopCapture: jest.fn(),
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
          capture: jest.fn(() => ({ then: callback => callback({ path: '/comment.mov' }) })),
          stopCapture: jest.fn(),
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
          capture: jest.fn(() => ({ then: callback => callback({ path: '/comment.mov' }) })),
          stopCapture: jest.fn(),
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
          capture: jest.fn(() => new Promise(() => {})),
          stopCapture: jest.fn(),
        }
      }
    }
    return renderer.create(<VideoRecorder {...props} />, options || { createNodeMock })
  }
})
