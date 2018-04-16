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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import TabRow from '../TabRow'

const template = {
  ...require('../../../__templates__/tab'),
}

const defaultProps = {
  tab: template.tab(),
  courseColor: 'white',
  onPress: () => {},
}

describe('TabRow', () => {
  it('renders correctly', () => {
    const tree = shallow(<TabRow {...defaultProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows a default icon', () => {
    const props = {
      ...defaultProps,
      tab: template.tab({ id: 'test default icon' }),
    }
    const tree = shallow(<TabRow {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('can be selected', () => {
    const tree = shallow(<TabRow {...defaultProps} selected />)
    expect(tree).toMatchSnapshot()
  })

  it('can be pressed', () => {
    const onPressed = jest.fn()
    const props = {
      ...defaultProps,
      onPress: onPressed,
    }

    const tree = shallow(<TabRow {...props} />)
    expect(tree).toMatchSnapshot()
    tree.find('Row').simulate('press')
    expect(onPressed).toHaveBeenCalledTimes(1)
  })

  it('uses attendance tab image', () => {
    const props = {
      ...defaultProps,
      attendanceTabID: defaultProps.tab.id,
    }
    const tree = shallow(<TabRow {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('uses attendance lti image', () => {
    const props = {
      ...defaultProps,
      tab: template.tab({ id: '/external_tool/' }),
    }
    const tree = shallow(<TabRow {...props} />)
    expect(tree).toMatchSnapshot()
  })
})
