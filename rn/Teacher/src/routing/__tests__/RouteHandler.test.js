//
// Copyright (C) 2018-present Instructure, Inc.
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
