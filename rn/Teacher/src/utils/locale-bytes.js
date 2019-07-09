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

const units = {
  TB: ((1 << 30) * 1024),
  GB: 1 << 30,
  MB: 1 << 20,
  KB: 1 << 10,
  B: 1,
}
type Unit = $Keys<typeof units>
const unitList: Unit[] = Object.keys(units)

type Options = {
  separator?: string,
  style?: string,
  unit?: Unit,
}

export const unitFor = (bytes: number): Unit => {
  const abs = Math.abs(bytes)
  return unitList.find(unit => abs >= units[unit]) || 'B'
}

export default function (bytes: number, options: Options = {}): ?string {
  if (!Number.isFinite(bytes)) return null
  const {
    separator = ' ',
    style,
    unit = unitFor(bytes),
  } = options
  return i18n.number(bytes / units[unit], style) + separator + unit
}
