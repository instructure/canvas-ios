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
import HomeTabRow from '../HomeTabRow'

const template = {
  ...require('../../../__templates__/tab'),
  ...require('../../../__templates__/course'),
}

const defaultProps = {
  tab: template.tab(),
  course: template.course({ 'default_view': 'assignments' }),
  courseColor: 'white',
  onPress: () => {},
}

describe('HomeTabRow', () => {
  it('renders correctly', () => {
    const tree = shallow(<HomeTabRow {...defaultProps} />)
    expect(tree).toMatchSnapshot()
  })

  it('renders correctly for each type', () => {
    const types = ['assignments', 'feed', 'wiki', 'modules', 'syllabus', 'whatisthis']
    types.forEach((type) => {
      const course = template.course({ 'default_view': type })
      const tree = shallow(<HomeTabRow {...defaultProps} course={course} />)
      expect(tree).toMatchSnapshot()
    })
  })

  it('can be selected', () => {
    const tree = shallow(<HomeTabRow {...defaultProps} selected />)
    expect(tree).toMatchSnapshot()
  })

  it('can be pressed', () => {
    const onPressed = jest.fn()
    const props = {
      ...defaultProps,
      onPress: onPressed,
    }

    const tree = shallow(<HomeTabRow {...props} />)
    expect(tree).toMatchSnapshot()
    tree.find('FeatureRow').simulate('press')
    expect(onPressed).toHaveBeenCalledTimes(1)
  })
})
