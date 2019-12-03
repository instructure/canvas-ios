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

import {
  processColor,
  Image,
} from 'react-native'

import Images from '../../images'
import * as utils from '../utils'

describe('routing utils', () => {
  describe('processConfig', () => {
    const warn = console.warn
    beforeEach(() => {
      console.warn = jest.fn()
    })
    afterEach(() => {
      console.warn = warn
    })

    it('processes config', () => {
      const id = 'test'
      const testID = 'testID'
      const configure = (id, func) => {
        return ''
      }
      const config = {
        children: [],
        testID,
        func: (id, value) => { return 'func' },
        someColor: '#fff',
        someImage: Images.add,
        stuff: [
          {
            trump: 'fired comey this week',
          },
        ],
        bananas: 'are not ripe',
      }

      const result = utils.processConfig(config, id, configure)
      const expected = {
        bananas: 'are not ripe',
        testID,
        func: '',
        someColor: processColor('#fff'),
        someImage: Image.resolveAssetSource(Images.add),
        stuff: [
          {
            trump: 'fired comey this week',
          },
        ],
      }
      expect(result).toMatchObject(expected)
    })

    it('handles edge cases', () => {
      const configure = (id, func) => {
        return ''
      }
      const config = {
        func: (id, value) => { return 'func' },
      }
      const result = utils.processConfig(config, '', configure)
      const expected = {}
      expect(result).toMatchObject(expected)
      expect(console.warn).toHaveBeenCalled()
    })
  })

  describe('isRegularDisplayMode', () => {
    it('handles empty traits', () => {
      let traits = {}
      const result = utils.isRegularDisplayMode(traits)
      expect(result).toBe(false)
    })

    it('handles regular traits', () => {
      let traits = {
        window: { horizontal: 'regular', vertical: 'regular' },
        screen: { horizontal: 'regular', vertical: 'regular' },
      }
      const result = utils.isRegularDisplayMode(traits)
      expect(result).toBe(true)
    })

    it('handles compact traits', () => {
      let traits = {
        window: { horizontal: 'compact', vertical: 'regular' },
        screen: { horizontal: 'compact', vertical: 'regular' },
      }
      const result = utils.isRegularDisplayMode(traits)
      expect(result).toBe(false)
    })
  })
})
