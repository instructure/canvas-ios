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
import ExperimentalFeature from '../ExperimentalFeature'

describe('ExperimentalFeature', () => {
  it('uses the remote config key in the settings key', () => {
    expect(new ExperimentalFeature('test').settingsKey).toEqual('ExperimentalFeature.test')
  })

  it('uses Settings by default', () => {
    Settings.set({ 'ExperimentalFeature.test': true })
    expect(new ExperimentalFeature('test').isEnabled).toEqual(true)
    Settings.set({ 'ExperimentalFeature.test': false })
  })

  it('sets value in Settings', () => {
    let feature = new ExperimentalFeature('test')
    feature.isEnabled = true
    expect(Settings.get('ExperimentalFeature.test')).toEqual(true)
  })
})
