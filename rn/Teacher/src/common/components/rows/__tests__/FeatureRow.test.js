// @flow

import FeatureRow from '../FeatureRow'
import { shallow } from 'enzyme'
import 'react-native'
import React from 'react'

describe('FeatureRow', () => {
  let props
  beforeEach(() => {
    props = {
      title: 'Title of the row',
      subtitle: 'Subtitle',
    }
  })

  it('renders', () => {
    expect(shallow(<FeatureRow {...props} />)).toMatchSnapshot()
  })
})
