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

import RouteHandler from '../RouteHandler'

describe('Route', () => {
  it('splits template into segments', () => {
    expect(new RouteHandler('/a//b/:c/d/*e').segments).toEqual([
      'a',
      'b',
      ':c',
      'd',
      '*e',
    ])
  })

  describe('match', () => {
    it('returns matched params', () => {
      expect(new RouteHandler('/a//b/:c/d/*e').match('a/b//c/d/e//f/g')).toEqual({
        c: 'c',
        e: 'e/f/g',
      })
    })

    it('ignores leading api/v1', () => {
      expect(new RouteHandler('/a//b/:c/d/*e').match('/api/v1/a/b//c/d/e//f/g')).toEqual({
        c: 'c',
        e: 'e/f/g',
      })
    })

    it('returns undefined if too short', () => {
      expect(new RouteHandler('/a//b/:c/d').match('a/b/c')).toBeUndefined()
    })

    it('returns undefined if too long', () => {
      expect(new RouteHandler('/a//b/:c/d').match('a/b/c/d/e')).toBeUndefined()
    })

    it('returns undefined if no match found', () => {
      expect(new RouteHandler('a').match('b')).toBeUndefined()
    })
  })
})
