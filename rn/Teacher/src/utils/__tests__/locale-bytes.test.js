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

import bytes from '../locale-bytes'

describe('locale-bytes', () => {
  it('returns null on inifity', () => {
    expect(bytes(Infinity)).toBeNull()
  })

  it('should format as TB if greater than 1 TB', () => {
    expect(bytes(1234567890123)).toBe('1.12 TB')
  })

  it('should format as GB if greater than 1 GB', () => {
    expect(bytes(1234567890)).toBe('1.15 GB')
  })

  it('should format as MB if greater than 1 MB', () => {
    expect(bytes(1234567)).toBe('1.18 MB')
  })

  it('should format as KB if greater than 1 KB', () => {
    expect(bytes(1234)).toBe('1.21 KB')
  })

  it('should format as B if less than than 1 KB', () => {
    expect(bytes(123)).toBe('123 B')
  })

  it('should format as B if less than than 1 B', () => {
    expect(bytes(0.123)).toBe('0.12 B')
  })

  it('can be styled using options', () => {
    expect(bytes(1234.56, {
      style: 'integer',
      separator: ';',
      unit: 'B',
    })).toBe('1,235;B')
  })
})
