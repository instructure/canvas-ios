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

import { shallow } from 'enzyme'
import React from 'react'
import TabRow from '../TabRow'
import Images from '../../../images'
import instIcon from '../../../images/inst-icons'
import * as template from '../../../__templates__'

const defaultProps = {
  tab: template.tab(),
  courseColor: 'white',
  onPress: () => {},
}

describe('TabRow', () => {
  it('shows a default icon', () => {
    const props = {
      ...defaultProps,
      tab: template.tab({ id: 'test default icon' }),
    }
    const tree = shallow(<TabRow {...props} />)
    expect(tree.find('Row').prop('image')).toEqual(instIcon('courses'))
  })

  it('can be selected', () => {
    const tree = shallow(<TabRow {...defaultProps} selected />)
    expect(tree.find('Row').prop('selected')).toBe(true)
  })

  it('can be pressed', () => {
    const onPressed = jest.fn()
    const props = {
      ...defaultProps,
      onPress: onPressed,
    }

    const tree = shallow(<TabRow {...props} />)
    tree.find('Row').simulate('press')
    expect(onPressed).toHaveBeenCalledTimes(1)
  })

  it('uses attendance tab image', () => {
    const props = {
      ...defaultProps,
      attendanceTabID: defaultProps.tab.id,
    }
    const tree = shallow(<TabRow {...props} />)
    expect(tree.find('Row').prop('image')).toEqual({ uri: 'attendance' })
  })

  it('uses attendance lti image', () => {
    const props = {
      ...defaultProps,
      tab: template.tab({ id: '/external_tool/' }),
    }
    const tree = shallow(<TabRow {...props} />)
    expect(tree.find('Row').prop('image')).toEqual(instIcon('lti'))
  })

  it('renders hidden if hidden', () => {
    const props = {
      ...defaultProps,
      tab: template.tab({ id: 'files', hidden: true }),
    }
    const tree = shallow(<TabRow {...props} />)
    const accessories = shallow(tree.find('Row').prop('accessories'))
    expect(accessories.prop('source')).toEqual(Images.invisible)
  })

  it('does not render hidden icon not hidden', () => {
    const props = {
      ...defaultProps,
      tab: template.tab({ id: 'files', hidden: false }),
    }
    const tree = shallow(<TabRow {...props} />)
    expect(tree.find('Row').prop('accessories')).toBeFalsy()
  })

  it('renders the right icon', () => {
    const iconFor = id =>
      shallow(<TabRow {...defaultProps} tab={template.tab({ id })} />)
        .find('Row').prop('image')
    expect(iconFor('announcements')).toEqual(instIcon('announcement'))
    expect(iconFor('application')).toEqual(instIcon('lti'))
    expect(iconFor('assignments')).toEqual(instIcon('assignment'))
    expect(iconFor('collaborations')).toEqual({ uri: 'collaborations' })
    expect(iconFor('conferences')).toEqual({ uri: 'conferences' })
    expect(iconFor('discussions')).toEqual(instIcon('discussion'))
    expect(iconFor('files')).toEqual(instIcon('folder'))
    expect(iconFor('grades')).toEqual(instIcon('gradebook'))
    expect(iconFor('home')).toEqual(instIcon('home'))
    expect(iconFor('link')).toEqual(instIcon('link'))
    expect(iconFor('modules')).toEqual(instIcon('module'))
    expect(iconFor('outcomes')).toEqual(instIcon('outcomes'))
    expect(iconFor('pages')).toEqual(instIcon('document'))
    expect(iconFor('people')).toEqual(instIcon('group'))
    expect(iconFor('quizzes')).toEqual(instIcon('quiz'))
    expect(iconFor('settings')).toEqual(instIcon('settings'))
    expect(iconFor('syllabus')).toEqual(instIcon('rubric'))
    expect(iconFor('tools')).toEqual(instIcon('lti'))
    expect(iconFor('user')).toEqual(instIcon('user'))
  })
})
