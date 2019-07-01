//
// Copyright (C) 2017-present Instructure, Inc.
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

import React from 'react'
import { shallow } from 'enzyme'
import GroupTopicChildren from '../GroupTopicChildren'
import * as template from '../../../../__templates__/'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

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
