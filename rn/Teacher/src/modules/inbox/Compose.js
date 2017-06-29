// @flow

import React, { PureComponent } from 'react'
import ReactNative, {
  View,
  StyleSheet,
  TextInput,
  Text,
  TouchableHighlight,
  TouchableOpacity,
  Image,
  LayoutAnimation,
  requireNativeComponent,
  Alert,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import Images from '../../images'
import Actions from './actions'
import Screen from '../../routing/Screen'
import colors from '../../common/colors'
import DisclosureIndicator from '../../common/components/DisclosureIndicator'
import RowWithSwitch from '../../common/components/rows/RowWithSwitch'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import AutoGrowingTextInput from '../../common/components/AutoGrowingTextInput'
import ModalActivityIndicator from '../../common/components/ModalActivityIndicator'
import AddressBookToken from './components/AddressBookToken'
import { createConversation, addMessage } from '../../api/canvas-api/conversations'
import axios from 'axios'
const ScrollViewDisabler = requireNativeComponent('ScrollViewDisabler')

type OwnProps = {
  conversationID?: string,
}

type ComposeProps = {
  navigator: Navigator,
  refreshInboxSent: Function,
  recipients?: AddressBookResult[],
  subject?: string,
  contextCode?: string,
  contextName?: string,
  course?: Course,
  canAddRecipients: boolean,
  canSelectCourse: boolean,
  onlySendIndividualMessages: boolean,
}

type ComposeState = {
  sendDisabled: boolean,
  sendToAll: boolean,
  recipients: AddressBookResult[],
  contextCode: ?string,
  contextName: ?string,
  body: ?string,
  subject: ?string,
  pending: boolean,
}

export class Compose extends PureComponent {
  props: ComposeProps & OwnProps
  state: ComposeState
  scrollView: KeyboardAwareScrollView

  static defaultProps = {
    canAddRecipients: true,
    canSelectCourse: true,
    canEditSubject: true,
    onlySendIndividualMessages: false,
  }

  constructor (props: ComposeProps) {
    super(props)

    this.state = {
      sendDisabled: true,
      sendToAll: props.onlySendIndividualMessages,
      recipients: props.recipients || [],
      contextCode: props.contextCode || null,
      contextName: props.contextName || null,
      body: null,
      subject: props.subject || null,
      pending: false,
    }
  }

  cancelCompose = () => {
    this.props.navigator.dismiss()
  }

  selectCourse = () => {
    this.props.navigator.show(
      '/conversations/course-select',
      {
        modal: true,
        modalPresentationStyle: 'fullscreen',
      },
      {
        onSelect: (course: Course) => {
          this.props.navigator.dismiss()
          const contextName = course.name
          const contextCode = `course_${course.id}`
          this.setStateAndUpdate({ contextName, contextCode, recipients: [] })
        },
      }
    )
  }

  sendMessage = () => {
    const state = this.state
    const convo: CreateConversationParameters = {
      recipients: state.recipients.map((r) => r.id),
      body: state.body || '',
      subject: state.subject || '',
      group_conversation: !state.sendToAll,
    }
    this.setState({ pending: true })
    const promise = this.props.conversationID ? addMessage(this.props.conversationID, convo) : createConversation(convo)
    promise.then((response) => {
      this.props.refreshInboxSent()
      this.props.navigator.dismissAllModals()
    }).catch((thrown) => {
      this.setState({
        pending: false,
      })
      if (!axios.isCancel(thrown)) {
        setTimeout(() => {
          Alert.alert(i18n('An error occurred'), thrown.message)
        }, 1000)
      }
    })
  }

  _validateSendButton = () => {
    const state = this.state
    const sendDisabled = !(state.recipients.length > 0 && state.body && state.body.length > 0)
    this.setState({
      sendDisabled,
    })
  }

  _bodyChanged = (body) => {
    this.setStateAndUpdate({ body })
  }

  _subjectChanged = (subject) => {
    this.setStateAndUpdate({ subject })
  }

  _openAddressBook = () => {
    const onSelect = (selected) => {
      this.props.navigator.dismiss()
      const recipients = this.state.recipients.concat(selected.filter(i => !this.state.recipients.map(ii => ii.id).includes(i.id)))
      this.setStateAndUpdate({ recipients })
    }

    const onCancel = () => this.props.navigator.dismiss()

    this.props.navigator.show('/address-book', { modal: true }, { onSelect, onCancel, context: this.state.contextCode, name: this.state.contextName })
  }

  _deleteRecipient = (id: string) => {
    const recipients = this.state.recipients.filter((recipient) => {
      return recipient.id !== id
    })
    LayoutAnimation.easeInEaseOut()
    this.setState({
      recipients,
    })
  }

  toggleSendAll = (value: boolean) => {
    this.setState({
      sendToAll: value,
    })
  }

  scrollToEnd = (e: any) => {
    this.scrollView.scrollToFocusedInput(ReactNative.findNodeHandle(e.target))
  }

  setStateAndUpdate = (state: any) => {
    this.setState(state, () => {
      this._validateSendButton()
    })
  }

  componentWillUnmount () {
    this.props.conversationID && this.props.refreshConversationDetails(this.props.conversationID)
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
        <View style={{ flex: 1 }}>
          <ModalActivityIndicator text={i18n('Sending...')} visible={this.state.pending}/>
          <KeyboardAwareScrollView
            style={styles.compose}
            ref={e => { this.scrollView = e }}
            contentContainerStyle={{ flexGrow: 1, paddingBottom: 16 }}
          >
            <TouchableHighlight underlayColor='#fff' style={styles.wrapper} onPress={this.props.canSelectCourse ? this.selectCourse : null}>
              <View style={styles.courseSelect}>
                <Text style={[styles.courseSelectText, this.state.contextName ? styles.courseSelectedText : undefined]}>
                  { this.state.contextName || i18n('Select a course') }
                </Text>
                { this.props.canSelectCourse &&
                  <DisclosureIndicator />
                }
              </View>
            </TouchableHighlight>
            { Boolean(this.state.contextCode) &&
              <View style={[styles.wrapper, styles.toContainer]}>
                <View style={{ padding: 6, paddingLeft: 0, height: 54, justifyContent: 'center' }}>
                  <Text style={styles.courseSelectText}>{i18n('To')}</Text>
                </View>
                <View style={styles.tokenContainer}>
                  {this.state.recipients.map((r) => {
                    return (<AddressBookToken item={r} delete={this._deleteRecipient} />)
                  })}
                </View>
                { this.props.canAddRecipients &&
                  <TouchableOpacity onPress={this._openAddressBook} style={{ height: 54, justifyContent: 'center' }} accessibilityTraits={['button']} accessibilityLabel={i18n('Add recipient')}>
                    <Image source={Images.add} style={{ tintColor: colors.primaryButton }} />
                  </TouchableOpacity>
                }
              </View>
            }
            <View style={styles.wrapper}>
              <TextInput
                placeholder={i18n('Subject')}
                value={this.props.canEditSubject ? this.state.subject : this.state.subject || i18n('(no subject)')}
                style={styles.cell}
                placeholderTextColor={colors.lightText}
                onChangeText={this._subjectChanged}
                editable={this.props.canEditSubject}
              />
            </View>
            { !this.props.onlySendIndividualMessages &&
              <RowWithSwitch
                border='bottom'
                title={i18n('Send individual message to each recipient')}
                onValueChange={this.toggleSendAll}
                value={this.state.sendToAll}
                identifier='compose-message.send-all-toggle'
              />
            }
            <ScrollViewDisabler style={[styles.message, styles.messageWrapper]}>
              <AutoGrowingTextInput
                placeholder={i18n('Compose message')}
                style={styles.cell}
                placeholderTextColor={colors.lightText}
                defaultHeight={54}
                onContentSizeChange={this.scrollToEnd}
                onChangeText={this._bodyChanged}
                testID='compose-message.body-text-input'
                extraHeight={20}
              />
            </ScrollViewDisabler>
          </KeyboardAwareScrollView>
        </View>
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
  message: {
    fontSize: 16,
    lineHeight: 19,
    paddingTop: global.style.defaultPadding / 1.25,
    paddingBottom: global.style.defaultPadding / 1.25,
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
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
  courseSelectedText: {
    color: colors.darkText,
  },
  toContainer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    minHeight: 54,
  },
  tokenContainer: {
    flexDirection: 'row',
    padding: 6,
    flex: 1,
    flexWrap: 'wrap',
  },
})

export function mapStateToProps (): any {
  return {}
}

const Connected = connect(mapStateToProps, Actions)(Compose)
export default (Connected: PureComponent<any, any, any>)
