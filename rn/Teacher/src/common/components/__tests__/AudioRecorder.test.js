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
import {
  Alert,
} from 'react-native'
import renderer from 'react-test-renderer'
import AudioRecorder from '../AudioRecorder'
import explore from '../../../../test/helpers/explore'
import { AudioRecorder as RNAudioRecorder } from 'react-native-audio'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
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
    const recordBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.recordButton')
    recordBtn.props.onPress()
    expect(recorder.toJSON()).toMatchSnapshot()
  })

  it('renders stopped state', () => {
    RNAudioRecorder.stopRecording = jest.fn(() => RNAudioRecorder.onFinished(data))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.recordButton')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.stopButton')
    stopBtn.props.onPress()
    expect(recorder.toJSON()).toMatchSnapshot()
  })

  it('renders reset state', () => {
    RNAudioRecorder.stopRecording = jest.fn(() => RNAudioRecorder.onFinished(data))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.recordButton')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.stopButton')
    stopBtn.props.onPress()
    const resetBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.clearButton')
    resetBtn.props.onPress()
    expect(recorder.toJSON()).toMatchSnapshot()
  })

  it('calls cancel', async () => {
    const cancelBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.cancelButton')
    await cancelBtn.props.onPress()
    expect(props.onCancel).toHaveBeenCalled()
  })

  it('calls onFinishedRecording with data', () => {
    RNAudioRecorder.stopRecording = jest.fn(() => RNAudioRecorder.onFinished(data))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.recordButton')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.stopButton')
    stopBtn.props.onPress()
    const doneBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.sendButton')
    doneBtn.props.onPress()
    expect(props.onFinishedRecording).toHaveBeenCalledWith({
      fileName: expect.any(String),
      filePath: data.audioFileURL,
    })
  })

  it('removes cancel button while recording', () => {
    const recordBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.recordButton')
    recordBtn.props.onPress()
    const cancelBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.cancelButton')
    expect(cancelBtn).toBeNull()
  })

  it('alerts start recording errors', () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    RNAudioRecorder.startRecording = jest.fn(() => { throw new Error('fail') })
    const recordBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.recordButton')
    recordBtn.props.onPress()
    expect(spy).toHaveBeenCalled()
  })

  it('alerts stop recording errors', () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    RNAudioRecorder.stopRecording = jest.fn(() => { throw new Error('fail') })
    const recordBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.recordButton')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.stopButton')
    stopBtn.props.onPress()
    expect(spy).toHaveBeenCalled()
  })

  it('records finish recording errors', () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    const error = {
      status: 'NOT OK',
    }
    RNAudioRecorder.stopRecording = jest.fn(() => RNAudioRecorder.onFinished(error))
    const recordBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.recordButton')
    recordBtn.props.onPress()
    const stopBtn: any = explore(recorder.toJSON()).selectByID('AudioRecorder.stopButton')
    stopBtn.props.onPress()
    expect(spy).toHaveBeenCalledWith('Recording failed')
  })
})
