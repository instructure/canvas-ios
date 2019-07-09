//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// @flow

import { shallow } from 'enzyme'
import React from 'react'
import { ConferenceList } from '../ConferenceList'
import * as templates from '../../../../__templates__'
import { alertError } from '../../../../redux/middleware/error-handler'

jest.mock('../../../../redux/middleware/error-handler', () => {
  return { alertError: jest.fn() }
})

let props = { }

describe('ConferenceList List', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    props = {
      course: templates.course(),
      navigator: templates.navigator(),
      conferences: [templates.conference()],
      color: '#F00',
      pending: false,
      isLoading: false,
      loadError: null,
      refresh: jest.fn(),
    }
  })

  it('renders', () => {
    props.conferences = null
    const tree = shallow(<ConferenceList { ...props } />)
    expect(tree).toMatchSnapshot()
  })

  it('renders with rows', () => {
    const tree = shallow(<ConferenceList { ...props } />)
    expect(tree).toMatchSnapshot()
  })

  it('shows conference on press', () => {
    props.navigator = templates.navigator({ show: jest.fn() })
    const conference = templates.conference()
    const tree = shallow(<ConferenceList { ...props } />)
    tree.find('FlatList').dive().find('Row').first().simulate('Press', conference)
    expect(props.navigator.show).toHaveBeenCalledWith(conference.join_url)
  })

  it('shows conference on press with no join url', () => {
    props.navigator = templates.navigator({ show: jest.fn() })
    const conference = templates.conference({ join_url: null })
    props.conferences = [conference]
    const tree = shallow(<ConferenceList { ...props } />)
    tree.find('FlatList').dive().find('Row').first().simulate('Press', conference)
    expect(props.navigator.show).toHaveBeenCalledWith('http://mobiledev.instructure.com/courses/1/conferences/1/join')
  })

  it('alerts on new loadError', () => {
    const tree = shallow(<ConferenceList {...props} />)
    tree.setProps({ loadError: null })
    expect(alertError).not.toHaveBeenCalled()
    const loadError = new Error()
    tree.setProps({ loadError })
    expect(alertError).toHaveBeenCalledWith(loadError)
  })
})
