// @flow
import React, { Component } from 'react'
import { View, Text, StyleSheet } from 'react-native'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import { getTermsOfService } from '../../canvas-api/apis/account'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import WebContainer from '../../common/components/WebContainer'
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

  donePressed = () => {
    this.props.navigator.dismiss()
  }

  render () {
    return (
      <Screen
        title={i18n('Terms Of Use')}
        leftBarButtons={[{
          testID: 'tos.done',
          title: i18n('Done'),
          style: 'done',
          action: this.donePressed,
        }]}
        navBarColor={colors.navBarColor}
        navBarButtonColor={colors.navBarButtonColor}
        statusBarStyle={colors.statusBarStyle}
      >
        {this.state.loading
          ? <ActivityIndicatorView />
          : this.state.termsError
            ? <View style={styles.container}>
                <Text>{i18n('There was a problem retreiving the Terms Of Use')}</Text>
              </View>
            : <View style={styles.container}>
                <WebContainer
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
