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

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import { shallow } from 'enzyme'
import GroupTopicChildren from '../GroupTopicChildren'
import * as template from '../../../../__templates__/'

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

describe('GroupTopicChildren', () => {
  it('renders topic children', async () => {
    let group1 = template.group({ id: '1', name: 'One' })
    let group2 = template.group({ id: '2', name: 'Two' })
    let props = {
      courseID: '1',
      topicChildren: [
        { id: '11', group_id: '1' },
        { id: '22', group_id: '2' },
      ],
      getGroupsForCourse: jest.fn(() => ({
        data: [group1, group2],
      })),
    }
    let view = shallow(<GroupTopicChildren {...props} />)
    await view.update()
    expect(view.find('[testID="GroupTopicChildren.group-1.label"]').prop('children')).toEqual('One')
    expect(view.find('[testID="GroupTopicChildren.group-2.label"]').prop('children')).toEqual('Two')
  })

  it('navigates to child', async () => {
    let group = template.group({ id: '1' })
    let props = {
      courseID: '1',
      topicChildren: [
        { id: '11', group_id: group.id },
      ],
      getGroupsForCourse: jest.fn(() => ({
        data: [group],
      })),
      navigator: template.navigator(),
    }
    let view = shallow(<GroupTopicChildren {...props} />)
    await view.update()
    let row = view.find('[testID="GroupTopicChildren.group-1.button"]')
    row.simulate('Press')
    expect(props.navigator.show).toHaveBeenCalledWith('/groups/1/discussion_topics/11')
  })
})
