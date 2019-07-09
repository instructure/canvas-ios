//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import React, { Component } from 'react'
import { View, Text, StyleSheet } from 'react-native'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import { getTermsOfService } from '../../canvas-api/apis/account'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import CanvasWebView from '../../common/components/CanvasWebView'

type Props = {
  navigator: Navigator,
  getTermsOfService: () => ApiPromise<TermsOfService>,
}

type State = {
  loading: boolean,
  termsContent: string,
  termsError: boolean,
}

export default class TermsOfUse extends Component<Props, State> {
  state = {
    loading: true,
    termsContent: '',
    termsError: false,
  }

  static defaultProps = {
    getTermsOfService,
  }

  componentDidMount = async () => {
    try {
      let { data: terms } = await this.props.getTermsOfService()
      this.setState({
        loading: false,
        termsContent: terms.content || i18n('Account has no Terms of Use'),
      })
    } catch (err) {
      this.setState({
        loading: false,
        termsError: true,
      })
    }
  }

  render () {
    return (
      <Screen title={i18n('Terms Of Use')} >
        {this.state.loading
          ? <ActivityIndicatorView />
          : this.state.termsError
            ? <View style={styles.container}>
              <Text>{i18n('There was a problem retrieving the Terms Of Use')}</Text>
            </View>
            : <View style={styles.container}>
              <CanvasWebView
                html={this.state.termsContent}
                style={{ flex: 1 }}
                navigator={this.props.navigator}
              />
            </View>
        }
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: 8,
  },
})
