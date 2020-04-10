//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import * as templates from '../../../__templates__'
import LiveConferenceRow from '../LiveConferenceRow'

describe('LiveConferenceRow', () => {
  const defaults = {
    conference: templates.liveConference({}),
    onDismiss () {},
    navigator: templates.navigator(),
  }

  it('renders conference title if no contextName is available', () => {
    const tree = shallow(<LiveConferenceRow {...defaults} />)
    expect(tree.find('SubTitle').prop('children')).toBe(defaults.conference.title)
  })

  it('renders conference contextName if available', () => {
    const tree = shallow(
      <LiveConferenceRow
        {...defaults}
        conference={{ ...defaults.conference, contextName: 'Course 1' }}
      />
    )
    expect(tree.find('SubTitle').prop('children')).toBe('Course 1')
  })

  it('can dismiss the conference row', () => {
    const onDismiss = jest.fn()
    const tree = shallow(<LiveConferenceRow {...defaults} onDismiss={onDismiss} />)
    tree.find(`[testID='LiveConference.1.dismissButton']`).simulate('Press')
    expect(onDismiss).toHaveBeenCalledWith('1')
  })

  it('can navigate to the conference', () => {
    const navigator = templates.navigator()
    const tree = shallow(<LiveConferenceRow {...defaults} navigator={navigator} />)
    tree.find(`[testID='LiveConference.1.navigateButton']`).simulate('Press')
    expect(navigator.show).toHaveBeenCalledWith('/courses/1/conferences/1/join')
  })
})
