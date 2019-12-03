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

import React from 'react'
import { shallow } from 'enzyme'
import AccessIcon, { type Props } from '../AccessIcon'
import icon from '../../../images/inst-icons'
import app from '../../../modules/app'

describe('AccessIcon', () => {
  let props: Props
  beforeEach(() => {
    props = {
      entry: {},
      tintColor: '#fff',
      image: icon('instructure', 'line'),
      showAccessIcon: true,
      disableAppSpecificChecks: true,
    }
    app.setCurrentApp('teacher')
  })

  it('shows published when not locked or hidden', () => {
    props.entry.published = true
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toEqual(icon('publish', 'solid'))
  })

  it('shows unpublished when published is false', () => {
    props.entry.published = false
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toEqual(icon('no', 'solid'))
  })

  it('published takes precedence over other properties', () => {
    props.entry.published = true
    props.entry.hidden = true
    props.entry.locked = true
    props.entry.unlock_at = '2018-01-01T12:00:00.000Z'
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toEqual(icon('publish', 'solid'))
  })

  it('shows unpublished when locked', () => {
    props.entry.locked = true
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toEqual(icon('no', 'solid'))
  })

  it('shows resticted when hidden', () => {
    props.entry.hidden = true
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toEqual(icon('cloudLock', 'line'))
  })

  it('shows resticted when unlock_at is specified', () => {
    props.entry.unlock_at = '2018-01-01T12:00:00.000Z'
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toEqual(icon('cloudLock', 'line'))
  })

  it('shows resticted when lock_at is specified', () => {
    props.entry.lock_at = '2018-01-01T12:00:00.000Z'
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toEqual(icon('cloudLock', 'line'))
  })

  it('has option to hide access icon', () => {
    props.showAccessIcon = false
    let tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('[testID="access-icon-icon"]')).toHaveLength(0)

    props.showAccessIcon = true
    tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('[testID="access-icon-icon"]')).toHaveLength(1)
  })

  it('turns off access icon for student app', () => {
    app.setCurrentApp('student')
    props.disableAppSpecificChecks = false
    props.showAccessIcon = true
    let tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('[testID="access-icon-icon"]')).toHaveLength(0)
  })
})
