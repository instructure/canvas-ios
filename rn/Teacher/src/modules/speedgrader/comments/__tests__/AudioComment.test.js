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
import { AudioComment, type Props } from '../AudioComment'
import explore from '../../../../../test/helpers/explore'
import template from '../../../../utils/template'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

const templates = {
  sound: template({
    getDuration: jest.fn(() => 0),
    getCurrentTime: jest.fn(),
    play: jest.fn(),
    stop: jest.fn(),
  }),
}

describe('AudioComment', () => {
  let props: Props
  beforeEach(() => {
    jest.useFakeTimers()
    props = {
      url: 'https://notorious.com/audio',
      downloadAudio: jest.fn(() => Promise.resolve('/audio.mp4')),
      loadAudio: jest.fn(() => Promise.resolve(templates.sound())),
      stopDownload: jest.fn(),
      from: 'me',
    }
  })

  afterEach(() => {
    jest.clearAllTimers()
  })

  it('renders default', () => {
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders from them', () => {
    props.from = 'them'
    expect(render(props).toJSON()).toMatchSnapshot()
  })

  it('renders label when not playing', () => {
    const label = explore(render(props).toJSON()).selectByID('audio-comment.label')
    expect(label).not.toBeNull()
  })

  it('renders player when playing', async () => {
    const view = render(props)
    const label: any = explore(view.toJSON()).selectByID('audio-comment.label')
    await label.props.onPress()
    const player = explore(view.toJSON()).selectByID('audio-comment.player')
    expect(player).not.toBeNull()
  })

  it('hides player when playing stops', async () => {
    const sound = templates.sound({
      play: jest.fn(callback => callback(true)),
    })
    props.loadAudio = jest.fn(() => Promise.resolve(sound))
    const view = render(props)
    const label: any = explore(view.toJSON()).selectByID('audio-comment.label')
    await label.props.onPress()
    const player = explore(view.toJSON()).selectByID('audio-comment.player')
    expect(player).toBeNull()
  })

  it('alerts when downloading audio fails', async () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    props.downloadAudio = jest.fn(() => Promise.reject(new Error()))
    const view = render(props)
    const label: any = explore(view.toJSON()).selectByID('audio-comment.label')
    await label.props.onPress()
    expect(spy).toHaveBeenCalledWith('Failed to load audio')
  })

  it('alerts when playback fails', async () => {
    const spy = jest.fn()
    // $FlowFixMe
    Alert.alert = spy
    const sound = templates.sound({
      play: jest.fn(callback => callback(false)),
    })
    props.loadAudio = jest.fn(() => Promise.resolve(sound))
    const view = render(props)
    const label: any = explore(view.toJSON()).selectByID('audio-comment.label')
    await label.props.onPress()
    expect(spy).toHaveBeenCalledWith('Audio playback failed')
  })

  it('stops player when stop pressed', async () => {
    const spy = jest.fn()
    const sound = templates.sound({ stop: spy })
    props.loadAudio = jest.fn(() => Promise.resolve(sound))
    const view = render(props)
    const label: any = explore(view.toJSON()).selectByID('audio-comment.label')
    await label.props.onPress()
    const stop: any = explore(view.toJSON()).selectByID('audio-comment.stop-btn')
    stop.props.onPress()
    const player = explore(view.toJSON()).selectByID('audio-comment.player')
    expect(player).toBeNull()
    expect(spy).toHaveBeenCalled()
  })

  it('moves the scrubber with the current time', async () => {
    const sound = templates.sound({
      getDuration: jest.fn(() => 10),
      getCurrentTime: jest.fn(callback => callback(5)),
    })
    props.loadAudio = jest.fn(() => Promise.resolve(sound))
    const view = render(props)
    const label: any = explore(view.toJSON()).selectByID('audio-comment.label')
    await label.props.onPress()
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('stops download on unmount', async () => {
    const spy = jest.fn()
    props.stopDownload = spy
    props.downloadAudio = jest.fn((url, jobCapture) => {
      jobCapture(1)
      return new Promise((resolve, reject) => {})
    })
    const view = render(props)
    const label: any = explore(view.toJSON()).selectByID('audio-comment.label')
    label.props.onPress()
    view.getInstance().componentWillUnmount()
    expect(spy).toHaveBeenCalledWith(1)
  })

  function render (props: Props): any {
    return renderer.create(<AudioComment {...props} />)
  }
})
