// @flow

import { shallow } from 'enzyme'
import React from 'react'
import { accountNotification } from '../../../__templates__/account-notification'
import GlobalAnnouncementRow from '../GlobalAnnouncementRow'

describe('GlobalAnnouncementRow', () => {
  const defaults = {
    notification: accountNotification({}),
    onDismiss () {},
  }

  it('renders error announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={accountNotification({ icon: 'error' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders calendar announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={accountNotification({ icon: 'calendar' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders warning announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={accountNotification({ icon: 'warning' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders question announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={accountNotification({ icon: 'question' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders information announcements', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={accountNotification({ icon: 'information' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders unexpected icon as information', () => {
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={accountNotification({ icon: 'bogus' })}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  it('can dismiss the notification', () => {
    const onDismiss = jest.fn()
    const tree = shallow(
      <GlobalAnnouncementRow
        {...defaults}
        notification={accountNotification({ id: '34' })}
        onDismiss={onDismiss}
      />
    )
    tree.find('[testID="global-announcement-row.button"]').simulate('Press')
    expect(onDismiss).toHaveBeenCalledWith('34')
    tree.find('[testID="global-announcement-row.expand"]').simulate('Press')
    tree.find('[testID="global-announcement-row.dismiss"]').simulate('Press')
    expect(onDismiss).toHaveBeenCalledTimes(2)
  })
})
