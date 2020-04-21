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
import { Alert } from 'react-native'
import renderer from 'react-test-renderer'
import { MediaComment, type Props } from '../MediaComment'
import explore from '../../../../test/helpers/explore'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('../AudioRecorder', () => 'AudioRecorder')
  .mock('react-native-camera', () => {
    const React = require.requireActual('react')
    return { RNCamera: class Camera extends React.Component {
        static Constants = { Type: { back: 1, front: 2 } }
        render () { return null }
        recordAsync = jest.fn(() => ({ then: callback => callback({ uri: '/comment.mov' }) }))
        stopRecording = jest.fn()
    } }
  })

describe('MediaComment', () => {
  let props: Props
  beforeEach(() => {
    props = {
      onFinishedUploading: jest.fn(),
      onCancel: jest.fn(),
      uploadMedia: jest.fn(),
      mediaType: 'audio',
    }
  })

  it('renders defaults', () => {
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('uploads media when audio finishes recording', () => {
    const spy = jest.fn()
    props.uploadMedia = spy
    const recorder = explore(render(props).toJSON()).selectByType('AudioRecorder')
    recorder.props.onFinishedRecording({ fileName: 'foo.mp4', filePath: '/foo.mp4' })
    expect(spy).toHaveBeenCalledWith('/foo.mp4', 'audio')
  })

  it('notifies when finished uploading', async () => {
    const spy = jest.fn()
    props.onFinishedUploading = spy
    props.uploadMedia = jest.fn(() => Promise.resolve('1'))
    const recorder = explore(render(props).toJSON()).selectByType('AudioRecorder')
    await recorder.props.onFinishedRecording({ fileName: 'foo.mp4', filePath: '/foo.mp4' })
    expect(spy).toHaveBeenCalledWith({
      fileName: 'foo.mp4',
      filePath: '/foo.mp4',
      mediaID: '1',
      mediaType: 'audio',
    })
  })

  it('alerts when upload fails', async () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    props.uploadMedia = jest.fn(() => Promise.reject(new Error()))
    const recorder = explore(render(props).toJSON()).selectByType('AudioRecorder')
    await recorder.props.onFinishedRecording({ fileName: 'foo.mp4', filePath: '/foo.mp4' })
    expect(spy).toHaveBeenCalledWith('Failed to upload media comment')
  })

  it('renders videos', () => {
    props.mediaType = 'video'
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  function render (props: Props): any {
    const createNodeMock = ({ type }) => {
      if (type === 'AudioRecorder') {
        return {
          prepareRecording: jest.fn(),
        }
      }
    }
    return renderer.create(<MediaComment {...props} />, { createNodeMock })
  }
})
