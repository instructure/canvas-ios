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

import i18n from 'format-message'
import React, { Component } from 'react'
import ReactNative, {
  AlertIOS,
  DatePickerIOS,
  StyleSheet,
  View,
} from 'react-native'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import api from '../../canvas-api'
import Screen from '../../routing/Screen'
import Colors from '../../common/colors'
import Images from '../../images'
import EditSectionHeader from '../../common/components/EditSectionHeader'
import RequiredFieldSubscript from '../../common/components/RequiredFieldSubscript'
import Row from '../../common/components/rows/Row'
import RowWithDateInput from '../../common/components/rows/RowWithDateInput'
import RowWithTextInput from '../../common/components/rows/RowWithTextInput'
import RowSeparator from '../../common/components/rows/RowSeparator'
import SavingBanner from '../../common/components/SavingBanner'
import { alertError } from '../../redux/middleware/error-handler'
import EditUsageRights from './EditUsageRights'

type Props = {
  contextID?: string,
  context?: CanvasContext,
  delete: (string, force?: boolean) => Promise<any>,
  item: Object,
  itemID: string,
  navigator: Navigator,
  onChange?: (Object) => any,
  onDelete?: (Object) => any,
  style?: any,
  update: (string, Object) => Promise<any>,
  updateUsageRights?: (UpdateUsageRightsParameters) => Promise<any>,
  getCourseEnabledFeatures: typeof api.getCourseEnabledFeatures,
  getCourseLicenses: typeof api.getCourseLicenses,
}

type State = {
  updated: Object,
  pending: boolean,
  showAvailability: boolean,
  showLockedAt: boolean,
  showUnlockedAt: boolean,
  licenses: License[],
  features: string[],
  validation: {
    name: string,
    unlock_at: string,
    lock_at: string,
    usage_rights: string,
  },
}

export default class EditItem extends Component<Props, State> {
  static defaultProps = {
    getCourseEnabledFeatures: api.getCourseEnabledFeatures,
    getCourseLicenses: api.getCourseLicenses,
  }

  state: State = {
    updated: {
      ...this.props.item,
      name: this.props.item.name || this.props.item.display_name,
    },
    pending: false,
    showAvailability: !!(this.props.item.lock_at || this.props.item.unlock_at),
    showLockedAt: false,
    showUnlockedAt: false,
    licenses: [],
    features: [],
    validation: {
      name: '',
      unlock_at: '',
      lock_at: '',
      usage_rights: '',
    },
  }

  componentWillMount () {
    this.loadCourseLicenses()
  }

  async loadCourseLicenses () {
    const { contextID, context, getCourseLicenses, getCourseEnabledFeatures } = this.props
    if (!contextID || !this.isFile() || context !== 'courses') return
    try {
      const [ { data: licenses }, { data: features } ] = await Promise.all([
        getCourseLicenses(contextID),
        getCourseEnabledFeatures(contextID),
      ])
      this.setState({ licenses, features })
    } catch (e) {}
  }

  handleDone = async () => {
    const name = this.state.updated.name.trim()
    const nameError = name ? '' : i18n('A title is required')
    const { lock_at, unlock_at, locked, usage_rights: rights } = this.state.updated
    const lockError = (lock_at && unlock_at && Date.parse(unlock_at) > Date.parse(lock_at)) // eslint-disable-line camelcase
      ? i18n('Available from must be before Available to') : ''
    const rightsError = (
      this.state.features.includes('usage_rights_required') &&
      (!rights || !rights.use_justification) &&
      !locked
    ) ? i18n('This file must have usage rights set before it can be published.') : ''
    this.setState({
      validation: {
        name: nameError,
        lock_at: lockError,
        unlock_at: lockError,
        usage_rights: rightsError,
      },
    })
    if (nameError || lockError || rightsError) {
      return
    }

    const updated = { ...this.state.updated, name }
    const item = this.props.item
    if (Object.keys(updated).some(p => updated[p] !== item[p])) {
      this.setState({ pending: true })
      try {
        if (this.props.updateUsageRights && updated.usage_rights !== item.usage_rights) {
          await this.props.updateUsageRights(updated.usage_rights)
        }
        await this.props.update(item.id, updated)
        if (this.props.updateUsageRights && updated.usage_rights !== item.usage_rights) {
          await this.props.updateUsageRights(updated.usage_rights)
        }
      } catch (error) {
        this.setState({ pending: false })
        setTimeout(() => { alertError(error) }, 1000)
        return
      }
    }

    await this.props.navigator.dismiss()
    if (this.props.onChange) this.props.onChange(updated)
  }

  handleDelete = () => {
    const { updated: { name } } = this.state
    const isFile = this.isFile()
    AlertIOS.alert(
      isFile
        ? i18n('Are you sure you want to delete {name}?', { name })
        : i18n('Delete Folder?'),
      isFile
        ? null
        : i18n('Deleting this folder will also delete all of the files inside the folder.'),
      [
        { text: i18n('Cancel'), style: 'cancel' },
        { text: i18n('Delete'), onPress: this.handleDeleteConfirm },
      ],
    )
  }

  handleDeleteConfirm = async () => {
    const itemID = this.props.itemID
    this.setState({ pending: true })
    try {
      await this.props.delete(itemID, true)
    } catch (error) {
      this.setState({ pending: false })
      setTimeout(() => { alertError(error) }, 1000)
      return
    }
    await this.props.navigator.dismiss()
    if (this.props.onDelete) this.props.onDelete(this.props.item)
  }

  scrollView: KeyboardAwareScrollView
  scrollToInput = (event: Event) => {
    const input = ReactNative.findNodeHandle(event.target)
    this.scrollView.scrollToFocusedInput(input)
  }

  getAccessKey (folder: Folder) {
    if (folder.locked) return 'unpublish'
    if (folder.hidden || this.state.showAvailability) return 'restrict'
    return 'publish'
  }

  getAccessOptions () {
    return {
      publish: i18n('Publish'),
      unpublish: i18n('Unpublish'),
      restrict: i18n('Restricted Access'),
    }
  }

  handleAccess = () => {
    const { navigator } = this.props
    navigator.show('/picker', {}, {
      onSelect: this.handleAccessSelect,
      options: this.getAccessOptions(),
      selectedValue: this.getAccessKey(this.state.updated),
      title: i18n('Access'),
    })
  }

  handleAccessSelect = (key: string) => {
    this.props.navigator.pop()
    const updated = this.state.updated
    let changes = {}
    let showAvailability = false
    if (key === 'publish') {
      changes = { locked: false, hidden: false, lock_at: null, unlock_at: null }
    } else if (key === 'unpublish') {
      changes = { locked: true, hidden: false, lock_at: null, unlock_at: null }
    } else /* if (key === 'restrict') */ {
      if (updated.lock_at || updated.unlock_at) {
        showAvailability = true
      } else {
        changes = { locked: false, hidden: true, lock_at: null, unlock_at: null }
      }
    }
    this.setState({ updated: { ...updated, ...changes }, showAvailability })
  }

  get2ndAccessKey (folder: Folder) {
    if (folder.hidden) return 'hidden'
    if (this.state.showAvailability) return 'schedule'
  }

  get2ndAccessOptions () {
    return {
      hidden: this.isFile()
        ? i18n('Only available to students with link. Not available in student files.')
        : i18n('Hidden. Files inside will be available with links.'),
      schedule: i18n('Schedule student availability'),
    }
  }

  handle2ndAccess = () => {
    const { navigator } = this.props
    navigator.show('/picker', {}, {
      onSelect: this.handle2ndAccessSelect,
      options: this.get2ndAccessOptions(),
      selectedValue: this.get2ndAccessKey(this.state.updated),
      title: i18n('Restricted Access'),
    })
  }

  handle2ndAccessSelect = (key: string) => {
    this.props.navigator.pop()
    const updated = this.state.updated
    let changes = {}
    let showAvailability = false
    if (key === 'hidden') {
      changes = { locked: false, hidden: true, lock_at: null, unlock_at: null }
    } else /* if (key === 'schedule') */ {
      showAvailability = true
      changes = { locked: false, hidden: false }
    }
    this.setState({ updated: { ...updated, ...changes }, showAvailability })
  }

  isFile () {
    return this.props.item.size != null
  }

  render () {
    const {
      updated,
      pending,
      features,
      licenses,
      showAvailability,
      showLockedAt,
      showUnlockedAt,
      validation,
    } = this.state
    const isFile = this.isFile()
    const secondaryAccessKey = this.get2ndAccessKey(updated)
    const secondaryAccessTitle = secondaryAccessKey && this.get2ndAccessOptions()[secondaryAccessKey]
    return (
      <Screen
        title={isFile ? i18n('Edit File') : i18n('Edit Folder')}
        navBarTitleColors={Colors.darkText}
        navBarButtonColor={Colors.link}
        drawUnderNavBar
        dismissButtonTitle={i18n('Cancel')}
        rightBarButtons={[{
          testID: 'edit-item.done-btn',
          title: i18n('Done'),
          action: this.handleDone,
        }]}
      >
        <View style={{ flex: 1 }}>
          { pending && <SavingBanner /> }
          <KeyboardAwareScrollView
            style={styles.container}
            ref={view => { this.scrollView = view }}
          >
            {/* Title */}
            <EditSectionHeader title={i18n('Title')} />
            <RowWithTextInput
              border='both'
              style={styles.title}
              value={updated.name}
              placeholder={i18n('Title')}
              onChangeText={name => this.setState({ updated: { ...this.state.updated, name } }) }
              onFocus={this.scrollToInput}
              identifier='edit-item.name'
            />
            <RequiredFieldSubscript title={validation.name} visible={!!validation.name} />

            {/* Access */}
            <EditSectionHeader title={i18n('Access')} />
            <Row
              border='both'
              title={this.getAccessOptions()[this.getAccessKey(updated)]}
              titleStyles={{ fontWeight: 'normal' }}
              onPress={this.handleAccess}
              testID='edit-item.publish'
              disclosureIndicator
            />
            {secondaryAccessTitle &&
              <Row
                border='bottom'
                title={secondaryAccessTitle}
                titleStyles={{ fontWeight: 'normal' }}
                onPress={this.handle2ndAccess}
                testID='edit-item.hidden'
                disclosureIndicator
              />
            }

            {/* Availability */}
            {showAvailability &&
              <View>
                <EditSectionHeader title={i18n('Availability')} />
                <RowSeparator />
                <RowWithDateInput
                  border='both'
                  title={i18n('Available from')}
                  date={updated.unlock_at}
                  onPress={() => this.setState({ showUnlockedAt: !showUnlockedAt })}
                  showRemoveButton
                  onRemoveDatePress={() => this.setState({ updated: { ...this.state.updated, unlock_at: null } })}
                  testID='edit-item.unlock_at'
                />
                {showUnlockedAt &&
                  <DatePickerIOS
                    date={updated.unlock_at ? new Date(updated.unlock_at) : new Date()}
                    mode='date'
                    onDateChange={value => this.setState({ updated: { ...this.state.updated, unlock_at: value.toISOString() } })}
                  />
                }
                <RequiredFieldSubscript title={validation.unlock_at} visible={!!validation.unlock_at} />
                <RowWithDateInput
                  border='bottom'
                  title={i18n('Available to')}
                  date={updated.lock_at}
                  onPress={() => this.setState({ showLockedAt: !showLockedAt })}
                  showRemoveButton
                  onRemoveDatePress={() => this.setState({ updated: { ...this.state.updated, lock_at: null } })}
                  testID='edit-item.lock_at'
                />
                {showLockedAt &&
                  <DatePickerIOS
                    date={updated.lock_at ? new Date(updated.lock_at) : new Date()}
                    mode='date'
                    onDateChange={value => this.setState({ updated: { ...this.state.updated, lock_at: value.toISOString() } })}
                  />
                }
                <RequiredFieldSubscript title={validation.lock_at} visible={!!validation.lock_at} />
              </View>
            }

            {/* Usage Rights */}
            {features.includes('usage_rights_required') &&
              <View>
                <EditUsageRights
                  licenses={licenses}
                  rights={updated.usage_rights || undefined}
                  onChange={value => this.setState({ updated: { ...this.state.updated, usage_rights: value } })}
                />
                <RequiredFieldSubscript title={validation.usage_rights} visible={!!validation.usage_rights} />
              </View>
            }

            {/* Delete */}
            <View style={styles.emptyHeader} />
            <Row
              border='both'
              title={isFile ? i18n('Delete File') : i18n('Delete Folder')}
              titleStyles={{ color: Colors.destructiveButtonColor }}
              image={Images.trash}
              imageTint={Colors.destructiveButtonColor}
              onPress={this.handleDelete}
              testID='edit-item.delete'
            />
          </KeyboardAwareScrollView>
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.grey1,
  },
  title: {
    height: 45,
  },
  emptyHeader: {
    height: 48,
  },
})
