//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
