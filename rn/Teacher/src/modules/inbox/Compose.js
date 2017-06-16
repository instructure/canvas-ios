// @flow

import React, { PureComponent } from 'react'
import {
  View,
  StyleSheet,
  TextInput,
  Text,
  TouchableHighlight,
  requireNativeComponent,
} from 'react-native'
import i18n from 'format-message'
import Screen from '../../routing/Screen'
import colors from '../../common/colors'
import DisclosureIndicator from '../../common/components/DisclosureIndicator'
import RowWithSwitch from '../../common/components/rows/RowWithSwitch'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import AutoGrowingTextInput from '../../common/components/AutoGrowingTextInput'
const ScrollViewDisabler = requireNativeComponent('ScrollViewDisabler')

type ComposeProps = {
  navigator: Navigator,
}

type ComposeState = {
  sendDisabled: boolean,
  sendToAll: boolean,
}

export default class Compose extends PureComponent {
  props: ComposeProps
  state: ComposeState
  scrollView: KeyboardAwareScrollView

  constructor (props: ComposeProps) {
    super(props)

    this.state = {
      sendDisabled: true,
      sendToAll: false,
    }
  }

  cancelCompose = () => {
    this.props.navigator.dismiss()
  }

  selectCourse = () => {}

  sendMessage = () => {}

  toggleSendAll = (value: boolean) => {
    this.setState({
      sendToAll: value,
    })
  }

  scrollToEnd = () => {
    console.log('here')
    this.scrollView.scrollToEnd()
  }

  render () {
    return (
      <Screen
        navBarColor='#fff'
        navBarStyle='light'
        drawUnderNavBar={true}
        title={i18n('New Message')}
        leftBarButtons={[{
          title: i18n('Cancel'),
          testID: 'compose-message.cancel',
          action: this.cancelCompose,
        }]}
        rightBarButtons={[{
          disabled: this.state.sendDisabled,
          title: i18n('Send'),
          testID: 'compose-message.send',
          action: this.sendMessage,
          style: 'done',
        }]}
      >
        <KeyboardAwareScrollView
          style={styles.compose}
          ref={e => { this.scrollView = e }}
          contentContainerStyle={{ flexGrow: 1, paddingBottom: 16 }}
        >
          <TouchableHighlight underlayColor='#fff' style={styles.wrapper} onPress={this.selectCourse}>
            <View style={styles.courseSelect}>
              <Text style={styles.courseSelectText}>{i18n('Select a course')}</Text>
              <DisclosureIndicator />
            </View>
          </TouchableHighlight>
          <View style={styles.wrapper}>
            <TextInput
              placeholder={i18n('To')}
              style={styles.cell}
              placeholderTextColor={colors.lightText}
            />
          </View>
          <View style={styles.wrapper}>
            <TextInput
              placeholder={i18n('Subject')}
              style={styles.cell}
              placeholderTextColor={colors.lightText}
            />
          </View>
          <RowWithSwitch
            border='bottom'
            title={i18n('Send individual message to each recipient')}
            onValueChange={this.toggleSendAll}
            value={this.state.sendToAll}
            identifier='compose-message.send-all-toggle'
          />
          <ScrollViewDisabler style={[styles.wrapper, styles.messageWrapper]}>
            <AutoGrowingTextInput
              placeholder={i18n('Compose message')}
              style={styles.cell}
              placeholderTextColor={colors.lightText}
              defaultHeight={54}
              onContentSizeChange={this.scrollToEnd}
            />
          </ScrollViewDisabler>
        </KeyboardAwareScrollView>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  compose: {
    flex: 1,
  },
  cell: {
    height: 54,
    fontSize: 16,
    lineHeight: 19,
  },
  messageWrapper: {
    borderBottomWidth: 0,
    paddingVertical: 10,
  },
  wrapper: {
    borderBottomColor: '#C7CDD1',
    borderBottomWidth: StyleSheet.hairlineWidth,
    paddingHorizontal: 16,
  },
  courseSelect: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 54,
  },
  courseSelectText: {
    fontSize: 16,
    lineHeight: 19,
    color: colors.lightText,
  },
})
