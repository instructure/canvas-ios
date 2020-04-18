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

import i18n from 'format-message'
import {
  Alert,
  Linking,
  NativeModules,
} from 'react-native'

const CameraManager = NativeModules.RNCameraManager

type Permission = 'microphone' | 'camera' | 'photos'

type ErrorMessages = {
  microphone: string,
  camera: string,
  photos: string,
}

export type Permissions = {
  errorMessages: () => ErrorMessages,
  checkMicrophone: () => Promise<boolean>,
  checkCamera: () => Promise<boolean>,
  alert: (permission: Permission) => void,
}

function errorMessages (): ErrorMessages {
  return {
    microphone: i18n('You must enable Microphone permissions in Settings to record audio.'),
    camera: i18n('You must enable Camera and Microphone permissions in Settings to use the camera.'),
    photos: i18n('You must enable Photos permissions in Settings.'),
  }
}

function alert (permission: Permission) {
  Alert.alert(
    i18n('Permission Needed'),
    errorMessages()[permission],
    [
      { text: i18n('Cancel'), onPress: null, style: 'cancel' },
      {
        text: i18n('Settings'),
        onPress: () => {
          const url = 'app-settings:'
          Linking.canOpenURL(url).then(supported => supported && Linking.openURL(url))
        },
        style: 'default',
      },
    ],
  )
}

export default ({
  errorMessages,
  checkMicrophone: CameraManager.checkRecordAudioAuthorizationStatus,
  checkCamera: CameraManager.checkVideoAuthorizationStatus,
  alert,
}: Permissions)
