// @flow

const { it, expect } = global
import { DisconnectedLegoSets } from '../LegoSets'
import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

import { defaultState } from '../reducer'

declare var jest: any

jest.mock('Button', () => 'Button')

it('renders 0 sets correctly', () => {
  const props = defaultState
  const tree = renderer.create(
    <DisconnectedLegoSets { ...props } />
  ).toJSON()

  expect(tree).toMatchSnapshot('0-lego-sets')
})

it('renders 2 sets correctly', () => {
  const sets = [
    {
      name: 'The Batcave!',
      imageURL: 'https://legos.com/batcave',
    },
    {
      name: 'Epic Pirate Ship',
      imageURL: 'https://lego.com/pirates',
    },
  ]
  const props = { sets }
  const tree = renderer.create(
    <DisconnectedLegoSets { ...props } />
  ).toJSON()

  expect(tree).toMatchSnapshot('2-lego-sets')
})

it('can buy the Millenium Falcon set!', () => {
  const buyLegoSet = jest.fn()

  const props = {
    sets: [],
    buyLegoSet,
  }
  const tree = renderer.create(
    <DisconnectedLegoSets { ...props } />
  ).toJSON()

  const button: any = explore(tree).selectByID('toys.legos.buyLegos')
  button.props.onPress()

  expect(buyLegoSet).toHaveBeenCalledWith({
    name: 'The Millenium Falcon',
    imageURL: 'https://lego.com/falcon',
  })
})
