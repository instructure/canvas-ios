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
import {
  PickerIOS,
  View,
} from 'react-native'
import EditSectionHeader from '../../common/components/EditSectionHeader'
import RowWithDetail from '../../common/components/rows/RowWithDetail'
import RowWithTextInput from '../../common/components/rows/RowWithTextInput'

type Props = {
  licenses: License[],
  rights?: UsageRights,
  onChange: (UsageRights) => any,
}

type State = {
  showUsageRight: boolean,
  showLicense: boolean,
}

export default class EditUsageRights extends Component<Props, State> {
  state = {
    showUsageRight: false,
    showLicense: false,
  }

  getUseOptions () {
    return {
      own_copyright: i18n('I hold the copyright'),
      used_by_permission: i18n('I have permission to use file'),
      public_domain: i18n('Public Domain File'),
      fair_use: i18n('Fair Use Exception'),
      creative_commons: i18n('Creative Commons File'),
    }
  }

  handleChangeCopyright = (value: string) => this.props.onChange({
    ...this.props.rights,
    legal_copyright: value,
  })

  handleChangeJustification = (value: any) => this.props.onChange({
    ...this.props.rights,
    use_justification: value,
  })

  handleChangeLicense = (value: any) => this.props.onChange({
    ...this.props.rights,
    license: value,
  })

  render () {
    const { rights = {} } = this.props
    const { showUsageRight, showLicense } = this.state
    const useOptions = this.getUseOptions()
    const licenses = this.props.licenses.filter(({ id }) => id.startsWith('cc'))
    return (
      <View>
        <EditSectionHeader title={i18n('Usage Rights')} />
        <RowWithTextInput
          border='both'
          title={i18n('Copyright Holder')}
          value={rights.legal_copyright || ''}
          placeholder={i18n('Name')}
          onChangeText={this.handleChangeCopyright}
          inputWidth={200}
          identifier='edit-item.usage_rights.legal_copyright'
        />
        <RowWithDetail
          border='bottom'
          detail={useOptions[rights.use_justification]}
          detailSelected={showUsageRight}
          onPress={() => this.setState({ showUsageRight: !showUsageRight })}
          title={i18n('Usage Right')}
          testID='edit-item.usage_rights.use_justification'
        />
        {showUsageRight &&
          <PickerIOS
            selectedValue={rights.use_justification}
            onValueChange={this.handleChangeJustification}
            testID='edit-item.usage_rights.use_justification.picker'
          >
            {Object.keys(useOptions).map(value =>
              <PickerIOS.Item
                key={value}
                value={value}
                label={useOptions[value]}
              />
            )}
          </PickerIOS>
        }
        {rights.use_justification === 'creative_commons' &&
          <View>
            <RowWithDetail
              border='bottom'
              detail={(licenses.find(({ id }) => id === rights.license) || {}).name}
              detailSelected={showLicense}
              onPress={() => this.setState({ showLicense: !showLicense })}
              title={i18n('Creative Commons License')}
              testID='edit-item.usage_rights.license'
            />
            {showLicense &&
              <PickerIOS
                selectedValue={rights.license}
                onValueChange={this.handleChangeLicense}
                testID='edit-item.usage_rights.license.picker'
              >
                {licenses.map(({ id, name }) =>
                  <PickerIOS.Item
                    key={id}
                    value={id}
                    label={name}
                  />
                )}
              </PickerIOS>
            }
          </View>
        }
      </View>
    )
  }
}
