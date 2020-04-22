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

// @flow
import { shallow } from 'enzyme'
import React from 'react'
import SubmissionsHeader from '../SubmissionsHeader.js'
import defaultFilterOptions from '../../filter/filter-options'

let template = {
  ...require('../../../__templates__/helm'),
}

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

describe('SubmissionHeader', () => {
  it('navigates to filter when pressed', () => {
    let navigator = template.navigator()
    let filterOptions = defaultFilterOptions()
    const tree = shallow(
      <SubmissionsHeader filterOptions={filterOptions} navigator={navigator} />
    )

    let filterButton = tree.find('[testID="submission-list.filter"]')
    filterButton.simulate('Press')

    expect(navigator.show).toHaveBeenCalledWith(
      '/filter',
      { modal: true },
      { filterOptions, navigator }
    )
  })

  it('renders anonymous grading', () => {
    const tree = shallow(
      <SubmissionsHeader filterOptions={defaultFilterOptions()} anonymous />
    )
    expect(tree.find('[testID="SubmissionsHeader.subtitle"]').prop('children')).toBe('Anonymous grading')
  })
})

