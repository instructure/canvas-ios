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

import { getSession } from '../canvas-api/session'
import { Settings } from 'react-native'

export default class ExperimentalFeature {
  constructor (state) {
    this.state = state // true | false | 'beta' | string[]
  }

  get isEnabled () {
    if (ExperimentalFeature.allEnabled) { return true }
    const host = (getSession().baseURL || '').split('/')[2] || ''
    if (this.state === false) {
      return false
    } else if (this.state === true) {
      return true
    } else if (this.state === 'beta') {
      return host.includes('.beta.')
    } else if (Array.isArray(this.state)) {
      return this.state.includes(host)
    }
    return false
  }

  static get allEnabled () {
    return Boolean(Settings.get('ExperimentalFeature.allEnabled'))
  }
  static set allEnabled (value) {
    Settings.set({ 'ExperimentalFeature.allEnabled': value })
  }
}

// *** Please stay in sync with Core/AppEnvironment/ExperimentalFlags.swift ***
// There is no automatic syncing of individual flags, since they can't be async
// and should be static.
ExperimentalFeature.conferences = new ExperimentalFeature(false)
ExperimentalFeature.favoriteGroups = new ExperimentalFeature(false)
ExperimentalFeature.simpleDiscussionRenderer = new ExperimentalFeature(false)
ExperimentalFeature.graphqlSpeedGrader = new ExperimentalFeature(false)
ExperimentalFeature.newPageDetails = new ExperimentalFeature(false)
