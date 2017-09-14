/* @flow */

import React from 'react'
import { AlertIOS } from 'react-native'
import renderer from 'react-test-renderer'
import { MediaComment, type Props } from '../MediaComment'
import explore from '../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../AudioRecorder', () => 'AudioRecorder')

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
    AlertIOS.alert = spy
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
