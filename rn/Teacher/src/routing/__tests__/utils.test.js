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
        someImage: Images.canvasLogo,
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
        someImage: Image.resolveAssetSource(Images.canvasLogo),
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
