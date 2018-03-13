//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { NativeModules, NativeEventEmitter } from 'react-native'
import { type TraitCollection } from '../routing/Navigator'

const Manager = NativeModules.WindowTraitsManager

export type WindowTraits = $PropertyType<TraitCollection, 'window'>

let windowTraits: WindowTraits = {
  horizontal: 'compact',
  vertical: 'regular',
}
export default function currentWindowTraits () {
  return windowTraits
}

const updater = (traits) => {
  windowTraits = traits.window
}

const emitter = new NativeEventEmitter(Manager)
emitter.addListener('Update', updater)
Manager.currentWindowTraits(updater)
