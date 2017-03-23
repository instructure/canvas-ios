/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import { BetaFeedback } from '../BetaFeedback'
import explore from '../../../../test/helpers/explore'

jest
  .unmock('ScrollView')
  .mock('../../../api/session')

const template = {
  ...require('../../../__templates__/react-native-navigation'),
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

  it('should have a dismiss button', () => {
    expect(BetaFeedback.navigatorButtons.rightButtons).toMatchObject([{
      title: 'Done',
      id: 'dismiss',
      testID: 'beta-feedback.dismiss-btn',
    }])
  })

  it('should have a way to be dismissed', () => {
    let navHandler = () => {}
    const event = {
      type: 'NavBarButtonPress',
      id: 'dismiss',
    }
    const props = {
      ...defaultProps,
      navigator: template.navigator({
        dismissModal: jest.fn(),
        setOnNavigatorEvent: (callback) => { navHandler = callback },
      }),
    }

    renderer.create(
      <BetaFeedback {...props} />
    )

    navHandler(event)

    expect(props.navigator.dismissModal).toHaveBeenCalled()
  })
})
