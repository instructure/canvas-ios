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
import { View, Text, StyleSheet } from 'react-native'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import { getTermsOfService } from '../../canvas-api/apis/account'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import CanvasWebView from '../../common/components/CanvasWebView'
import colors from '../../common/colors'

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
      <Screen
        title={i18n('Terms Of Use')}
        navBarColor={colors.navBarColor}
        navBarButtonColor={colors.navBarTextColor}
        statusBarStyle={colors.statusBarStyle}
      >
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
