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
    tree.find('[testID="AccountNotification.34.toggleButton"]').simulate('Press')
    tree.find('[testID="AccountNotification.34.dismissButton"]').simulate('Press')
    expect(onDismiss).toHaveBeenCalledWith('34')
  })

  it('appends origin on navigation', () => {
    const show = jest.fn()
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={templates.accountNotification({ id: '34' })}
        navigator={templates.navigator({ show })}
      />
    )
    tree.find('CoreWebView').simulate('Navigation', '/files/1')
    expect(show).toHaveBeenCalledWith('/files/1?origin=globalAnnouncement', { deepLink: true })
    tree.find('CoreWebView').simulate('Navigation', '/files/1?verifier=abc')
    expect(show).toHaveBeenCalledWith('/files/1?verifier=abc&origin=globalAnnouncement', { deepLink: true })
  })
})
