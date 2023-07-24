//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */
import { Settings } from 'react-native'

export default class ExperimentalFeature {
  constructor (remoteConfigKey) {
    this.remoteConfigKey = remoteConfigKey
    this.settingsKey = `ExperimentalFeature.${remoteConfigKey}`
    this.enabled = Boolean(Settings.get(this.settingsKey))
  }

  get isEnabled () {
    return this.enabled
  }

  set isEnabled (value) {
    this.enabled = value
    Settings.set({ [this.settingsKey]: value })
  }

  static get allEnabled () {
    return Object.values(ExperimentalFeature).every(f => f.isEnabled)
  }

  static set allEnabled (newValue) {
    Object.values(ExperimentalFeature)
      .forEach(f => { f.isEnabled = newValue })
  }
}

// *** Please stay in sync with Core/AppEnvironment/ExperimentalFlags.swift ***
// There is no automatic syncing of individual flags, since they can't be async
// and should be static.
ExperimentalFeature.favoriteGroups = new ExperimentalFeature('favorite_groups')
ExperimentalFeature.nativeStudentInbox = new ExperimentalFeature('native_student_inbox')
