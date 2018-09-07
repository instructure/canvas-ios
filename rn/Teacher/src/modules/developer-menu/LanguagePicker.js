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
const { Helm } = NativeModules

type Language = { name: string, languageCode: string }

export default class LanguagePicker extends Component<any, any> {
  selectLanguage = async (languageCode: string) => {
    NativeModules.LocalizationManager.setCurrentLocale(languageCode)
    await this.props.navigator.dismiss()
    Helm.reload()
  }

  render () {
    const supportedLanguages: Array<Language> = [
      {
        name: 'English',
        languageCode: 'en',
      },
      {
        name: 'English (U.K.)',
        languageCode: 'en-GB',
      },
      {
        name: 'English (U.K.) HE',
        languageCode: 'en-GB-x-ukhe',
      },
      {
        name: 'English (Australian)',
        languageCode: 'en-AU',
      },
      {
        name: 'Spanish',
        languageCode: 'es',
      },
      {
        name: 'Danish',
        languageCode: 'da',
      },
      {
        name: 'Danish K12',
        languageCode: 'da-x-k12',
      },
      {
        name: 'German',
        languageCode: 'de',
      },
      {
        name: 'Chinese',
        languageCode: 'zh',
      },
      {
        name: 'Chinese (Hong Kong)',
        languageCode: 'zh-HK',
      },
      {
        name: 'Portuguese (Brazil)',
        languageCode: 'pt-BR',
      },
      {
        name: 'Portuguese',
        languageCode: 'pt',
      },
      {
        name: 'Arabic',
        languageCode: 'ar',
      },
      {
        name: 'Swedish',
        languageCode: 'sv',
      },
      {
        name: 'Swedish K12',
        languageCode: 'sv-x-k12',
      },
      {
        name: 'Norwegian',
        languageCode: 'nb',
      },
      {
        name: 'Norwegian K12',
        languageCode: 'nb-x-k12',
      },
    ].sort((a, b) => {
      if (a.name < b.name) return -1
      if (a.name > b.name) return 1
      return 0
    })

    return (
      <Screen
        title='Language Picker'
      >
        <ScrollView style={{ flex: 1 }}>
          {supportedLanguages.map((language) => {
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
