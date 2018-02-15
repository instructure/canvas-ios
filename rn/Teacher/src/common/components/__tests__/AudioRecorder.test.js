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
import {
  AlertIOS,
} from 'react-native'
import renderer from 'react-test-renderer'
import AudioRecorder from '../AudioRecorder'
import explore from '../../../../test/helpers/explore'
import { AudioRecorder as RNAudioRecorder } from 'react-native-audio'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('react-native-audio', () => ({
    AudioRecorder: {
      prepareRecordingAtPath: jest.fn(),
      startRecording: jest.fn(),
      stopRecording: jest.fn(),
      onProgress: jest.fn(),
      onFinished: jest.fn(),
    },
    AudioUtils: require.requireActual('react-native-audio').AudioUtils,
  }))

describe('AudioRecorder', () => {
  const data = {
    status: 'OK',
    audioFileURL: 'file://somewhere.m4a',
  }

  let recorder
  let props
  beforeEach(() => {
    jest.resetAllMocks()

    props = {
      onCancel: jest.fn(),
      onFinishedRecording: jest.fn(),
    }
    recorder = renderer.create(<AudioRecorder {...props} />)
  })

  it('renders default state', () => {
    expect(recorder.toJSON()).toMatchSnapshot()
  })

  it('renders recording state', () => {
    RNAudioRecorder.startRecording = jest.fn(() => RNAudioRecorder.onProgress({
      currentTime: 0,
    }))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.record-btn')
    recordBtn.props.onPress()
    expect(recorder.toJSON()).toMatchSnapshot()
  })

  it('renders stopped state', () => {
    RNAudioRecorder.stopRecording = jest.fn(() => RNAudioRecorder.onFinished(data))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.record-btn')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.stop-btn')
    stopBtn.props.onPress()
    expect(recorder.toJSON()).toMatchSnapshot()
  })

  it('renders reset state', () => {
    RNAudioRecorder.stopRecording = jest.fn(() => RNAudioRecorder.onFinished(data))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.record-btn')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.stop-btn')
    stopBtn.props.onPress()
    const resetBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.reset-btn')
    resetBtn.props.onPress()
    expect(recorder.toJSON()).toMatchSnapshot()
  })

  it('calls cancel', async () => {
    const cancelBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.cancel-btn')
    await cancelBtn.props.onPress()
    expect(props.onCancel).toHaveBeenCalled()
  })

  it('calls onFinishedRecording with data', () => {
    RNAudioRecorder.stopRecording = jest.fn(() => RNAudioRecorder.onFinished(data))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.record-btn')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.stop-btn')
    stopBtn.props.onPress()
    const doneBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.done-btn')
    doneBtn.props.onPress()
    expect(props.onFinishedRecording).toHaveBeenCalledWith({
      fileName: expect.any(String),
      filePath: data.audioFileURL,
    })
  })

  it('removes cancel button while recording', () => {
    const recordBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.record-btn')
    recordBtn.props.onPress()
    const cancelBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.cancel-btn')
    expect(cancelBtn).toBeNull()
  })

  it('alerts start recording errors', () => {
    const spy = jest.fn()
    // $FlowFixMe
    AlertIOS.alert = spy
    RNAudioRecorder.startRecording = jest.fn(() => { throw new Error('fail') })
    const recordBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.record-btn')
    recordBtn.props.onPress()
    expect(spy).toHaveBeenCalled()
  })

  it('alerts stop recording errors', () => {
    const spy = jest.fn()
    // $FlowFixMe
    AlertIOS.alert = spy
    RNAudioRecorder.stopRecording = jest.fn(() => { throw new Error('fail') })
    const recordBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.record-btn')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.stop-btn')
    stopBtn.props.onPress()
    expect(spy).toHaveBeenCalled()
  })

  it('records finish recording errors', () => {
    const spy = jest.fn()
    // $FlowFixMe
    AlertIOS.alert = spy
    const error = {
      status: 'NOT OK',
    }
    RNAudioRecorder.stopRecording = jest.fn(() => RNAudioRecorder.onFinished(error))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.record-btn')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('audio-recorder.stop-btn')
    stopBtn.props.onPress()
    expect(spy).toHaveBeenCalledWith('Recording failed')
  })
})
