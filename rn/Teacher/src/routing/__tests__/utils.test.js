// @flow

import {
  processColor,
  Image,
} from 'react-native'

import Images from '../../images'
import utils from '../utils'

describe('routing util tests', () => {
  test('process config', () => {
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

  test('edge cases', () => {
    const configure = (id, func) => {
      return ''
    }
    const config = {
      func: (id, value) => { return 'func' },
    }
    const result = utils.processConfig(config, '', configure)
    const expected = {}
    expect(result).toMatchObject(expected)
  })

  test('isRegularDisplayMode with empty traits', () => {
    let traits = {}
    const result = utils.isRegularDisplayMode(traits)
    expect(result).toBe(false)
  })

  test('isRegularDisplayMode with regular traits', () => {
    let traits = { 'window': { 'horizontal': 'regular' } }
    const result = utils.isRegularDisplayMode(traits)
    expect(result).toBe(true)
  })

  test('isRegularDisplayMode with compact traits', () => {
    let traits = { 'window': { 'horizontal': 'compact' } }
    const result = utils.isRegularDisplayMode(traits)
    expect(result).toBe(false)
  })

  test('check defaults with custom back button title', () => {
    let input = {
      backButtonTitle: 'Bananas',
      navBarTitle: 'Strawberries',
    }
    let output = utils.checkDefaults(input)
    expect(input).toEqual(output)

    input = {
      navBarTitle: 'I feel empty inside',
    }
    output = utils.checkDefaults(input)
    expect(output).toEqual({
      navBarTitle: 'I feel empty inside',
      backButtonTitle: 'Back',
    })
  })
})
