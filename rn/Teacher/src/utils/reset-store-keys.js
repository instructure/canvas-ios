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

export default function resetStoreKeys (object: Object): Object {
  let newObj = Object.keys(object).reduce((current, key) => {
    if (object[key] && typeof object[key] === 'object' && !Array.isArray(object[key])) {
      current[key] = resetStoreKeys(object[key])
    } else if (key === 'pending') {
      current.pending = 0
    } else {
      current[key] = object[key]
    }
    return current
  }, {})
  return newObj
}
