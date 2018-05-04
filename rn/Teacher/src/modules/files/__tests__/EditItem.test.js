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

/* eslint-disable flowtype/require-valid-file-annotation */
import React from 'react'
import { shallow } from 'enzyme'
import { AlertIOS } from 'react-native'
import { alertError } from '../../../redux/middleware/error-handler'

import EditItem from '../EditItem'

jest.useFakeTimers()
jest.mock('../../../redux/middleware/error-handler', () => {
  const alertError = error => { alertError.error = error }
  return { alertError }
})

const template = {
  ...require('../../../__templates__/folder'),
  ...require('../../../__templates__/file'),
}

const selector = {
  name: '[identifier="edit-item.name"]',
  publish: '[testID="edit-item.publish"]',
  hidden: '[testID="edit-item.hidden"]',
  unlock_at: '[testID="edit-item.unlock_at"]',
  lock_at: '[testID="edit-item.lock_at"]',
  delete: '[testID="edit-item.delete"]',
}

const updatedState = (tree: ShallowWrapper) => new Promise(resolve => tree.setState({}, resolve))

describe('EditItem folder', () => {
  let props
  beforeEach(() => {
    props = {
      itemID: '123',
      item: template.folder({ id: '123', name: 'Folder' }),
      navigator: {
        show: jest.fn(),
        dismiss: jest.fn(),
        pop: jest.fn(),
      },
    }
  })

  it('should render', () => {
    const tree = shallow(<EditItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows the type of restriction when hidden', () => {
    props.item.hidden = true
    const tree = shallow(<EditItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows availability when there is a lock_at date', () => {
    props.item.lock_at = '2017-11-17T00:00:00Z'
    const tree = shallow(<EditItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows availability when there is an unlock_at date', () => {
    props.item.unlock_at = '2017-11-17T00:00:00Z'
    const tree = shallow(<EditItem {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('scrolls to the name field when focused', () => {
    const scrollToFocusedInput = jest.fn()
    const tree = shallow(<EditItem {...props} />)
    tree.find('KeyboardAwareScrollView').getElement().ref({ scrollToFocusedInput })
    tree.find(selector.name).simulate('focus', {})
    expect(scrollToFocusedInput).toHaveBeenCalled()
  })

  it('can update the name', () => {
    const tree = shallow(<EditItem {...props} />)
    expect(tree.find(selector.name).prop('value')).toBe('Folder')
    tree.find(selector.name).simulate('ChangeText', 'renamed')
    expect(tree.find(selector.name).prop('value')).toBe('renamed')
  })

  it('shows the current access', async () => {
    const tree = shallow(<EditItem {...props} />)
    expect(tree.find(selector.publish).prop('title')).toBe('Publish')

    tree.find(selector.publish).simulate('Press')
    expect(props.navigator.show).toHaveBeenCalled()
    props.navigator.show.mock.calls[0][2].onSelect('unpublish')
    await updatedState(tree)
    expect(tree.find(selector.publish).prop('title')).toBe('Unpublish')

    tree.find(selector.publish).simulate('Press')
    props.navigator.show.mock.calls[1][2].onSelect('publish')
    await updatedState(tree)
    expect(tree.find(selector.publish).prop('title')).toBe('Publish')

    tree.find(selector.publish).simulate('Press')
    props.navigator.show.mock.calls[2][2].onSelect('restrict')
    await updatedState(tree)
    expect(tree.find(selector.publish).prop('title')).toBe('Restricted Access')
  })

  it('shows the current 2nd level access', async () => {
    props.item.hidden = true
    const tree = shallow(<EditItem {...props} />)
    expect(tree.find(selector.hidden).prop('title')).toBe('Hidden. Files inside will be available with links.')

    tree.find(selector.hidden).simulate('Press')
    expect(props.navigator.show).toHaveBeenCalledTimes(1)
    props.navigator.show.mock.calls[0][2].onSelect('schedule')
    await updatedState(tree)
    expect(tree.find(selector.hidden).prop('title')).toBe('Schedule student availability')

    tree.find(selector.hidden).simulate('Press')
    expect(props.navigator.show).toHaveBeenCalledTimes(2)
    props.navigator.show.mock.calls[1][2].onSelect('hidden')
    await updatedState(tree)
    expect(tree.find(selector.hidden).prop('title')).toBe('Hidden. Files inside will be available with links.')
  })

  it('shows availability when scheduling is picked', async () => {
    const tree = shallow(<EditItem {...props} />)
    expect(tree.find('[title="Availability"]').exists()).toBe(false)

    tree.find(selector.publish).simulate('Press')
    expect(props.navigator.show).toHaveBeenCalled()
    props.navigator.show.mock.calls[0][2].onSelect('restrict')
    await updatedState(tree)

    tree.find(selector.hidden).simulate('Press')
    expect(props.navigator.show).toHaveBeenCalledTimes(2)
    props.navigator.show.mock.calls[1][2].onSelect('schedule')
    await updatedState(tree)

    expect(tree.find('[title="Availability"]').exists()).toBe(true)
  })

  it('toggles the date pickers when rows are clicked', () => {
    props.item.lock_at = '2017-11-17T00:00:00Z'
    props.item.unlock_at = '2017-11-17T00:00:00Z'
    const tree = shallow(<EditItem {...props} />)

    tree.find(selector.unlock_at).simulate('Press')
    tree.find(selector.lock_at).simulate('Press')
    expect(tree.find('DatePickerIOS').length).toBe(2)

    tree.find(selector.unlock_at).simulate('Press')
    tree.find(selector.lock_at).simulate('Press')
    expect(tree.find('DatePickerIOS').length).toBe(0)
  })

  it('can update the unlock_at date', () => {
    props.item.unlock_at = '2017-11-17T00:00:00.000Z'
    const nextDate = '2017-11-24T00:00:00.000Z'
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.unlock_at).simulate('Press')
    tree.find('DatePickerIOS').simulate('DateChange', new Date(nextDate))
    expect(tree.find(selector.unlock_at).prop('date')).toBe(nextDate)

    tree.find(selector.unlock_at).simulate('RemoveDatePress')
    expect(tree.find(selector.unlock_at).prop('date')).toBe(null)
  })

  it('can update the lock_at date', () => {
    props.item.lock_at = '2017-11-17T00:00:00.000Z'
    const nextDate = '2017-11-24T00:00:00.000Z'
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.lock_at).simulate('Press')
    tree.find('DatePickerIOS').simulate('DateChange', new Date(nextDate))
    expect(tree.find(selector.lock_at).prop('date')).toBe(nextDate)

    tree.find(selector.lock_at).simulate('RemoveDatePress')
    expect(tree.find(selector.lock_at).prop('date')).toBe(null)
  })

  it('leaves the lock_at date when reselecting schedule', async () => {
    props.item.lock_at = '2017-11-17T00:00:00Z'
    const tree = shallow(<EditItem {...props} />)

    tree.find(selector.publish).simulate('Press')
    expect(props.navigator.show).toHaveBeenCalled()
    props.navigator.show.mock.calls[0][2].onSelect('restrict')
    await updatedState(tree)
    expect(tree.find(selector.lock_at).prop('date')).toBe(props.item.lock_at)
  })

  it('can delete the item', async () => {
    const deleting = Promise.resolve()
    const dismissing = Promise.resolve()
    props.delete = jest.fn(() => deleting)
    props.navigator.dismiss = jest.fn(() => dismissing)
    AlertIOS.alert = jest.fn()
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.delete).simulate('Press')
    expect(AlertIOS.alert).toHaveBeenCalledWith(
      'Delete Folder?',
      'Deleting this folder will also delete all of the files inside the folder.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', onPress: expect.any(Function) },
      ],
    )
    AlertIOS.alert.mock.calls[0][2][1].onPress()
    await deleting
    expect(props.delete).toHaveBeenCalledWith(props.itemID, true)
    await updatedState(tree)
    expect(tree.find('SavingBanner').exists()).toBe(true)

    await dismissing
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('calls onDelete when passed', async () => {
    const dismissing = Promise.resolve()
    props.delete = jest.fn(() => Promise.resolve())
    props.navigator.dismiss = jest.fn(() => dismissing)
    props.onDelete = jest.fn()
    AlertIOS.alert = jest.fn()
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.delete).simulate('Press')
    AlertIOS.alert.mock.calls[0][2][1].onPress()
    await dismissing
    await updatedState(tree)
    expect(props.onDelete).toHaveBeenCalled()
  })

  it('alerts if it cannot delete', async () => {
    const deleting = Promise.reject('oh noes!')
    props.delete = jest.fn(() => deleting)
    AlertIOS.alert = jest.fn()
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.delete).simulate('Press')
    AlertIOS.alert.mock.calls[0][2][1].onPress()
    await deleting.catch(() => {})
    jest.runOnlyPendingTimers()
    expect(alertError.error).toBe('oh noes!')
  })

  it('validates name on done', async () => {
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.name).simulate('ChangeText', ' \t')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    await updatedState(tree)
    expect(tree.find('RequiredFieldSubscript').at(0).prop('title'))
      .toBe('A title is required')
  })

  it('validates lock on done', async () => {
    props.item.unlock_at = '2017-11-18T00:00:00.000Z'
    props.item.lock_at = '2017-11-17T00:00:00.000Z'
    const tree = shallow(<EditItem {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    await updatedState(tree)
    expect(tree.find('RequiredFieldSubscript').at(1).prop('title'))
      .toBe('Available from must be before Available to')
  })

  it('just closes if done with no changes', () => {
    props.update = jest.fn()
    const tree = shallow(<EditItem {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.update).not.toHaveBeenCalled()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('shows an error alert if saving fails', async () => {
    const saveFailed = Promise.reject('oops!')
    props.update = jest.fn(() => saveFailed)
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.name).simulate('ChangeText', 'title2')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.update).toHaveBeenCalledWith(props.item.id, {
      ...props.item,
      name: 'title2',
    })
    await updatedState(tree)
    expect(tree.find('SavingBanner').exists()).toBe(true)
    await saveFailed.catch(() => {})
    jest.runOnlyPendingTimers()
    expect(alertError.error).toBe('oops!')
    await updatedState(tree)
    expect(tree.find('SavingBanner').exists()).toBe(false)
  })

  it('calls onChange if saved successfully', async () => {
    const saveSuccess = Promise.resolve()
    props.update = jest.fn(() => saveSuccess)
    props.onChange = jest.fn()
    const dismissing = Promise.resolve()
    props.navigator.dismiss = jest.fn(() => dismissing)
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.name).simulate('ChangeText', 'title3')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    const updated = { ...props.item, name: 'title3' }
    expect(props.update).toHaveBeenCalledWith(props.item.id, updated)
    await saveSuccess
    await dismissing
    expect(props.onChange).toHaveBeenCalledWith(updated)
  })
})

describe('EditItem file', () => {
  let props
  beforeEach(() => {
    props = {
      contextID: '1',
      context: 'courses',
      itemID: '123',
      item: template.file({ id: '123', display_name: 'passwords.txt' }),
      navigator: {
        show: jest.fn(),
        dismiss: jest.fn(),
        pop: jest.fn(),
      },
      getCourseEnabledFeatures: jest.fn(() => Promise.resolve({ data: [] })),
      getCourseLicenses: jest.fn(() => Promise.resolve({ data: [
        { id: 'private', name: 'Private (Copyrighted)' },
        { id: 'cc_by', name: 'CC Attribution' },
        { id: 'cc_by_nc_sa', name: 'CC Attribution Non-Commercial Share Alike' },
      ] })),
    }
  })

  it('renders text specifically for files', async () => {
    const deleting = Promise.resolve()
    const dismissing = Promise.resolve()
    props.delete = jest.fn(() => deleting)
    props.navigator.dismiss = jest.fn(() => dismissing)
    AlertIOS.alert = jest.fn()
    const tree = shallow(<EditItem {...props} />)
    tree.find(selector.delete).simulate('Press')
    expect(AlertIOS.alert).toHaveBeenCalledWith(
      'Are you sure you want to delete passwords.txt?',
      null,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', onPress: expect.any(Function) },
      ],
    )
    AlertIOS.alert.mock.calls[0][2][1].onPress()
    await deleting
    expect(props.delete).toHaveBeenCalled()
    await updatedState(tree)
    expect(tree.find('SavingBanner').exists()).toBe(true)

    await dismissing
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('renders usage rights editing when feature is enabled', async () => {
    const getting = Promise.resolve({ data: [ 'usage_rights_required' ] })
    props.getCourseEnabledFeatures = jest.fn(() => getting)
    props.item.usage_rights = {
      legal_copyright: '',
      use_justification: 'creative_commons',
      license: 'cc_by',
    }
    const tree = shallow(<EditItem {...props} />)
    await getting
    await updatedState(tree)
    expect(tree.state('features')).toEqual([ 'usage_rights_required' ])
    expect(tree.find('EditUsageRights').prop('rights')).toBe(props.item.usage_rights)
    expect(tree).toMatchSnapshot()
  })

  it('validates usage_rights on done', async () => {
    props.getCourseEnabledFeatures = jest.fn(() => Promise.resolve({ data: [ 'usage_rights_required' ] }))
    props.item.usage_rights = undefined
    props.item.locked = false
    const tree = shallow(<EditItem {...props} />)
    await Promise.resolve() // wait for features
    tree.find('Screen').prop('rightBarButtons')[0].action()
    await updatedState(tree)
    expect(tree.find('RequiredFieldSubscript').at(1).prop('title'))
      .toBe('This file must have usage rights set before it can be published.')
  })

  it('calls updateUsageRights if changed', async () => {
    const dismissing = Promise.resolve()
    const getting = Promise.resolve({ data: [ 'usage_rights_required' ] })
    props.getCourseEnabledFeatures = jest.fn(() => getting)
    props.update = jest.fn(() => Promise.resolve())
    props.updateUsageRights = jest.fn(() => Promise.resolve())
    props.navigator.dismiss = jest.fn(() => dismissing)
    const tree = shallow(<EditItem {...props} />)
    await getting
    await Promise.resolve()
    await updatedState(tree)
    const updatedRights = {
      legal_copyright: '(c) 2017 My Buddy',
      use_justification: 'used_by_permission',
    }
    tree.find('EditUsageRights').simulate('Change', updatedRights)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    await dismissing
    expect(props.updateUsageRights).toHaveBeenCalledWith(updatedRights)
  })
})
