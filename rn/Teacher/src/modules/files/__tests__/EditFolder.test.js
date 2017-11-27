//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow
import React from 'react'
import { shallow } from 'enzyme'
import { AlertIOS } from 'react-native'
import { alertError } from '../../../redux/middleware/error-handler'

import EditFolder from '../EditFolder'

jest.useFakeTimers()
jest.mock('../../../redux/middleware/error-handler', () => {
  const alertError = error => { alertError.error = error }
  return { alertError }
})

const template = {
  ...require('../../../__templates__/folder'),
}

const selector = {
  name: '[identifier="edit-folder.name"]',
  publish: '[testID="edit-folder.publish"]',
  hidden: '[testID="edit-folder.hidden"]',
  unlock_at: '[testID="edit-folder.unlock_at"]',
  lock_at: '[testID="edit-folder.lock_at"]',
  delete: '[testID="edit-folder.delete"]',
}

describe('EditFolder', () => {
  let props
  beforeEach(() => {
    props = {
      folderID: '123',
      folder: template.folder({ id: '123', name: 'Folder' }),
      navigator: {
        show: jest.fn(),
        dismiss: jest.fn(),
        pop: jest.fn(),
      },
    }
  })

  const updatedState = (tree: ShallowWrapper) => new Promise(resolve => tree.setState({}, resolve))

  it('should render', () => {
    const tree = shallow(<EditFolder {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows the type of restriction when hidden', () => {
    props.folder.hidden = true
    const tree = shallow(<EditFolder {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows availability when there is a lock_at date', () => {
    props.folder.lock_at = '2017-11-17T00:00:00Z'
    const tree = shallow(<EditFolder {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('shows availability when there is an unlock_at date', () => {
    props.folder.unlock_at = '2017-11-17T00:00:00Z'
    const tree = shallow(<EditFolder {...props} />)
    expect(tree).toMatchSnapshot()
  })

  it('scrolls to the name field when focused', () => {
    const scrollToFocusedInput = jest.fn()
    const tree = shallow(<EditFolder {...props} />)
    tree.find('KeyboardAwareScrollView').getElement().ref({ scrollToFocusedInput })
    tree.find(selector.name).simulate('focus', {})
    expect(scrollToFocusedInput).toHaveBeenCalled()
  })

  it('can update the name', () => {
    const tree = shallow(<EditFolder {...props} />)
    expect(tree.find(selector.name).prop('value')).toBe('Folder')
    tree.find(selector.name).simulate('ChangeText', 'renamed')
    expect(tree.find(selector.name).prop('value')).toBe('renamed')
  })

  it('shows the current access', async () => {
    const tree = shallow(<EditFolder {...props} />)
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
    props.folder.hidden = true
    const tree = shallow(<EditFolder {...props} />)
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
    const tree = shallow(<EditFolder {...props} />)
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
    props.folder.lock_at = '2017-11-17T00:00:00Z'
    props.folder.unlock_at = '2017-11-17T00:00:00Z'
    const tree = shallow(<EditFolder {...props} />)

    tree.find(selector.unlock_at).simulate('Press')
    tree.find(selector.lock_at).simulate('Press')
    expect(tree.find('DatePickerIOS').length).toBe(2)

    tree.find(selector.unlock_at).simulate('Press')
    tree.find(selector.lock_at).simulate('Press')
    expect(tree.find('DatePickerIOS').length).toBe(0)
  })

  it('can update the unlock_at date', () => {
    props.folder.unlock_at = '2017-11-17T00:00:00.000Z'
    const nextDate = '2017-11-24T00:00:00.000Z'
    const tree = shallow(<EditFolder {...props} />)
    tree.find(selector.unlock_at).simulate('Press')
    tree.find('DatePickerIOS').simulate('DateChange', new Date(nextDate))
    expect(tree.find(selector.unlock_at).prop('date')).toBe(nextDate)

    tree.find(selector.unlock_at).simulate('RemoveDatePress')
    expect(tree.find(selector.unlock_at).prop('date')).toBe(null)
  })

  it('can update the lock_at date', () => {
    props.folder.lock_at = '2017-11-17T00:00:00.000Z'
    const nextDate = '2017-11-24T00:00:00.000Z'
    const tree = shallow(<EditFolder {...props} />)
    tree.find(selector.lock_at).simulate('Press')
    tree.find('DatePickerIOS').simulate('DateChange', new Date(nextDate))
    expect(tree.find(selector.lock_at).prop('date')).toBe(nextDate)

    tree.find(selector.lock_at).simulate('RemoveDatePress')
    expect(tree.find(selector.lock_at).prop('date')).toBe(null)
  })

  it('leaves the lock_at date when reselecting schedule', async () => {
    props.folder.lock_at = '2017-11-17T00:00:00Z'
    const tree = shallow(<EditFolder {...props} />)

    tree.find(selector.publish).simulate('Press')
    expect(props.navigator.show).toHaveBeenCalled()
    props.navigator.show.mock.calls[0][2].onSelect('restrict')
    await updatedState(tree)
    expect(tree.find(selector.lock_at).prop('date')).toBe(props.folder.lock_at)
  })

  it('can delete the folder', async () => {
    const deleting = Promise.resolve()
    const dismissing = Promise.resolve()
    props.deleteFolder = jest.fn(() => deleting)
    props.navigator.dismiss = jest.fn(() => dismissing)
    AlertIOS.alert = jest.fn()
    const tree = shallow(<EditFolder {...props} />)
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
    expect(props.deleteFolder).toHaveBeenCalled()
    await updatedState(tree)
    expect(tree.find('SavingBanner').exists()).toBe(true)

    await dismissing
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('calls onDelete when passed', async () => {
    const dismissing = Promise.resolve()
    props.deleteFolder = jest.fn(() => Promise.resolve())
    props.navigator.dismiss = jest.fn(() => dismissing)
    props.onDelete = jest.fn()
    AlertIOS.alert = jest.fn()
    const tree = shallow(<EditFolder {...props} />)
    tree.find(selector.delete).simulate('Press')
    AlertIOS.alert.mock.calls[0][2][1].onPress()
    await dismissing
    await updatedState(tree)
    expect(props.onDelete).toHaveBeenCalled()
  })

  it('alerts if it cannot delete', async () => {
    const deleting = Promise.reject('oh noes!')
    props.deleteFolder = jest.fn(() => deleting)
    AlertIOS.alert = jest.fn()
    const tree = shallow(<EditFolder {...props} />)
    tree.find(selector.delete).simulate('Press')
    AlertIOS.alert.mock.calls[0][2][1].onPress()
    await deleting.catch(() => {})
    jest.runOnlyPendingTimers()
    expect(alertError.error).toBe('oh noes!')
  })

  it('dismisses on cancel', () => {
    const tree = shallow(<EditFolder {...props} />)
    tree.find('Screen').prop('leftBarButtons')[0].action()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('validates name on done', async () => {
    const tree = shallow(<EditFolder {...props} />)
    tree.find(selector.name).simulate('ChangeText', ' \t')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    await updatedState(tree)
    expect(tree.find('RequiredFieldSubscript').at(0).prop('title'))
      .toBe('A title is required')
  })

  it('validates lock on done', async () => {
    props.folder.unlock_at = '2017-11-18T00:00:00.000Z'
    props.folder.lock_at = '2017-11-17T00:00:00.000Z'
    const tree = shallow(<EditFolder {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    await updatedState(tree)
    expect(tree.find('RequiredFieldSubscript').at(1).prop('title'))
      .toBe('Available from must be before Available to')
  })

  it('just closes if done with no changes', () => {
    props.updateFolder = jest.fn()
    const tree = shallow(<EditFolder {...props} />)
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.updateFolder).not.toHaveBeenCalled()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('shows an error alert if saving fails', async () => {
    const saveFailed = Promise.reject('oops!')
    props.updateFolder = jest.fn(() => saveFailed)
    const tree = shallow(<EditFolder {...props} />)
    tree.find(selector.name).simulate('ChangeText', 'title2')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.updateFolder).toHaveBeenCalledWith(props.folder.id, {
      ...props.folder,
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
    props.updateFolder = jest.fn(() => saveSuccess)
    props.onChange = jest.fn()
    const dismissing = Promise.resolve()
    props.navigator.dismiss = jest.fn(() => dismissing)
    const tree = shallow(<EditFolder {...props} />)
    tree.find(selector.name).simulate('ChangeText', 'title3')
    tree.find('Screen').prop('rightBarButtons')[0].action()
    expect(props.updateFolder).toHaveBeenCalledWith(props.folder.id, {
      ...props.folder,
      name: 'title3',
    })
    await saveSuccess
    await dismissing
    expect(props.onChange).toHaveBeenCalledWith(props.folder.id)
  })
})
