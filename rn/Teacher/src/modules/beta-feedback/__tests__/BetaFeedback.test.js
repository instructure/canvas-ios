/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import BetaFeedback from '../BetaFeedback'
import explore from '../../../../test/helpers/explore'

jest
  .unmock('ScrollView')
  .mock('../../../api/session')

const template = {
  ...require('../../../__templates__/helm'),
}

const defaultProps = {
  navigator: template.navigator(),
}

describe('Beta Feedback form', () => {
  it('renders a uri', () => {
    const tree = renderer.create(
      <BetaFeedback {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()

    expect(
      explore(tree).query(({ props }) => {
        return props.source && props.source.uri
      })
    ).toHaveLength(1)
  })

  it('should have a way to be dismissed', () => {
    const props = {
      ...defaultProps,
      navigator: template.navigator({
        dismiss: jest.fn(),
      }),
    }
    const tree = renderer.create(
      <BetaFeedback {...props} />
    )
    tree.getInstance().dismiss()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })
})
