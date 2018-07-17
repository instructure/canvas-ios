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

// @flow

import { shallow } from 'enzyme'
import React from 'react'
import * as templates from '../../../__templates__'
import GlobalAnnouncementRow from '../GlobalAnnouncementRow'

describe('GlobalAnnouncementRow', () => {
  const defaults = {
    notification: templates.accountNotification({}),
    onDismiss () {},
    navigator: templates.navigator(),
  }

  it('renders error announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={templates.accountNotification({ icon: 'error' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders calendar announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={templates.accountNotification({ icon: 'calendar' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders warning announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={templates.accountNotification({ icon: 'warning' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders question announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={templates.accountNotification({ icon: 'question' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders information announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={templates.accountNotification({ icon: 'information' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders unexpected icon as information', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={templates.accountNotification({ icon: 'bogus' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('can dismiss the notification', () => {
    const onDismiss = jest.fn()
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={templates.accountNotification({ id: '34' })}
        onDismiss={onDismiss}
      />
    )
    tree.find('[testID="global-announcement-row.toggle"]').simulate('Press')
    tree.find('[testID="global-announcement-row.dismiss"]').simulate('Press')
    expect(onDismiss).toHaveBeenCalledWith('34')
  })
})
