//
// Copyright (C) 2016-present Instructure, Inc.
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

import React from 'react'
import { shallow } from 'enzyme'
import AccessIcon, { type Props } from '../AccessIcon'
import Images from '../../../images'
import app from '../../../modules/app'

describe('AccessIcon', () => {
  let props: Props
  beforeEach(() => {
    props = {
      entry: {},
      tintColor: '#fff',
      image: Images.kabob,
      showAccessIcon: true,
      disableAppSpecificChecks: true,
    }
  })

  it('shows published when not locked or hidden', () => {
    props.entry.published = true
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toBe(Images.publishedSmall)
    expect(tree).toMatchSnapshot()
  })

  it('shows unpublished when published is false', () => {
    props.entry.published = false
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toBe(Images.unpublishedSmall)
    expect(tree).toMatchSnapshot()
  })

  it('published takes precedence over other properties', () => {
    props.entry.published = true
    props.entry.hidden = true
    props.entry.locked = true
    props.entry.unlock_at = '2018-01-01T12:00:00.000Z'
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toBe(Images.publishedSmall)
    expect(tree).toMatchSnapshot()
  })

  it('shows unpublished when locked', () => {
    props.entry.locked = true
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toBe(Images.unpublishedSmall)
    expect(tree).toMatchSnapshot()
  })

  it('shows resticted when hidden', () => {
    props.entry.hidden = true
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toBe(Images.restricted)
    expect(tree).toMatchSnapshot()
  })

  it('shows resticted when unlock_at is specified', () => {
    props.entry.unlock_at = '2018-01-01T12:00:00.000Z'
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toBe(Images.restricted)
    expect(tree).toMatchSnapshot()
  })

  it('shows resticted when lock_at is specified', () => {
    props.entry.lock_at = '2018-01-01T12:00:00.000Z'
    const tree = shallow(<AccessIcon {...props} />)
    expect(tree.find('Image').at(1).prop('source')).toBe(Images.restricted)
    expect(tree).toMatchSnapshot()
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
