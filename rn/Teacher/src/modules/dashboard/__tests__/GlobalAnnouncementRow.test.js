// @flow

import React from 'react'
import 'react-native'
import GlobalAnnouncementRow from '../GlobalAnnouncementRow'
import renderer from 'react-test-renderer'

test('group row renders', () => {
  const tree = renderer.create(
    <GlobalAnnouncementRow
      style={{ margin: 8 }}
      color='pink'
      title='Pizza on 3'
      description='Come get some delicious pizza, @everyone!' />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
