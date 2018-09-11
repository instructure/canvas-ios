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

import React, { Component } from 'react'
import {
  ScrollView,
  NativeModules,
} from 'react-native'

import Screen from '../../routing/Screen'
import Row from '../../common/components/rows/Row'

type Language = { name: string, languageCode: string }
type State = {
  languages: Language[],
}

export default class LanguagePicker extends Component<Object, State> {
  state = {
    languages: [],
  }

  componentDidMount () {
    NativeModules.LocalizationManager.getLocales().then(languages => {
      this.setState({ languages })
    })
  }

  selectLanguage = async (languageCode: string) => {
    await this.props.navigator.dismiss()
    NativeModules.LocalizationManager.setCurrentLocale(languageCode)
  }

  render () {
    return (
      <Screen
        title='Language Picker'
      >
        <ScrollView style={{ flex: 1 }}>
          {this.state.languages.map((language) => {
            return (
              <Row
                title={language.name}
                subtitle={language.languageCode}
                key={language.languageCode}
                border='bottom'
                onPress={() => this.selectLanguage(language.languageCode)} />
            )
          })}
        </ScrollView>
      </Screen>
    )
  }
}
