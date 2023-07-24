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

// @flow

//
//  A simple wrapper around the CanvasAnalytics native module
//

import { NativeModules } from 'react-native'

const { CanvasAnalytics } = NativeModules

export function logEvent (name: string, parameters?: { [string]: any }): void {
  // Google Analytics needs to be disabled for now
// CanvasAnalytics.logEvent(name, parameters)
}

export function logScreenView (route: string): void {
  CanvasAnalytics.logScreenView(route)
}
