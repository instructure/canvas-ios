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

import i18n from 'format-message'
import React, { Component } from 'react'
import { View } from 'react-native'
import { Picker } from '@react-native-community/picker'
import { FormLabel } from '../../common/text'
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
        <FormLabel>{i18n('Usage Rights')}</FormLabel>
        <RowWithTextInput
          border='both'
          title={i18n('Copyright Holder')}
          value={rights.legal_copyright || ''}
          placeholder={i18n('Name')}
          onChangeText={this.handleChangeCopyright}
          inputWidth={200}
          identifier='FileEditor.copyrightField'
        />
        <RowWithDetail
          border='bottom'
          detail={useOptions[rights.use_justification]}
          detailSelected={showUsageRight}
          onPress={() => this.setState({ showUsageRight: !showUsageRight })}
          title={i18n('Usage Right')}
          testID='FileEditor.justificationButton'
        />
        {showUsageRight &&
          <Picker
            selectedValue={rights.use_justification}
            onValueChange={this.handleChangeJustification}
            testID='FileEditor.justificationPicker'
          >
            {Object.keys(useOptions).map(value =>
              <Picker.Item
                key={value}
                value={value}
                label={useOptions[value]}
              />
            )}
          </Picker>
        }
        {rights.use_justification === 'creative_commons' &&
          <View>
            <RowWithDetail
              border='bottom'
              detail={(licenses.find(({ id }) => id === rights.license) || {}).name}
              detailSelected={showLicense}
              onPress={() => this.setState({ showLicense: !showLicense })}
              title={i18n('Creative Commons License')}
              testID='FileEditor.licenseButton'
            />
            {showLicense &&
              <Picker
                selectedValue={rights.license}
                onValueChange={this.handleChangeLicense}
                testID='FileEditor.licensePicker'
              >
                {licenses.map(({ id, name }) =>
                  <Picker.Item
                    key={id}
                    value={id}
                    label={name}
                  />
                )}
              </Picker>
            }
          </View>
        }
      </View>
    )
  }
}
