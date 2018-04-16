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

import React, { PureComponent } from 'react'
import ReactNative, {
  View,
  StyleSheet,
  TextInput,
  TouchableHighlight,
  TouchableOpacity,
  Image,
  LayoutAnimation,
  Alert,
  processColor,
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
import ModalOverlay from '../../common/components/ModalOverlay'
import AddressBookToken from './components/AddressBookToken'
import { createConversation, addMessage, isAbort } from '../../canvas-api'
import { Text } from '../../common/text'
import throttle from 'lodash/throttle'

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
  includedMessages?: Array<ConversationMessage>,
  navBarTitle?: string,
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
  attachments: Attachment[],
}

export class Compose extends PureComponent<ComposeProps & OwnProps, ComposeState> {
  scrollView: KeyboardAwareScrollView

  static defaultProps = {
    canAddRecipients: true,
    canSelectCourse: true,
    canEditSubject: true,
    showCourseSelect: true,
    onlySendIndividualMessages: false,
  }

  state: ComposeState = {
    sendDisabled: true,
    sendToAll: this.props.onlySendIndividualMessages,
    recipients: this.props.recipients || [],
    contextCode: this.props.contextCode || null,
    contextName: this.props.contextName || null,
    body: null,
    subject: this.props.subject || null,
    pending: false,
    attachments: [],
  }

  cancelCompose = () => {
    this.props.navigator.dismiss()
  }

  selectCourse = () => {
    this.props.navigator.show(
      '/conversations/course-select',
      undefined,
      {
        onSelect: (course: Course) => {
          this.props.navigator.pop()
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
      group_conversation: true,
      included_messages: this.props.includedMessages && this.props.includedMessages.map(({ id }) => id),
      attachment_ids: this.state.attachments.map(a => a.id),
      context_code: state.contextCode || undefined,
    }

    if (this.state.sendToAll) {
      convo.bulk_message = 1
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
      if (!isAbort(thrown)) {
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

  adjust = throttle((e: any) => {
    const element = ReactNative.findNodeHandle(e.target)
    this.scrollView.scrollToFocusedInput(element)
  }, 250)

  scrollToEnd = (e: any) => {
    e.persist()
    this.adjust(e)
  }

  setStateAndUpdate = (state: any) => {
    this.setState(state, () => {
      this._validateSendButton()
    })
  }

  editAttachments = () => {
    this.props.navigator.show('/attachments', { modal: true }, {
      attachments: this.state.attachments,
      storageOptions: {
        uploadPath: '/users/self/files',
        targetFolderPath: 'my files/conversation attachments',
      },
      onComplete: this.setAttachments,
    })
  }

  setAttachments = (attachments: Attachment[]) => {
    this.setState({ attachments })
  }

  componentWillUnmount () {
    this.props.conversationID && this.props.refreshConversationDetails(this.props.conversationID)
  }

  render () {
    return (
      <Screen
        drawUnderNavBar
        title={this.props.navBarTitle || i18n('New Message')}
        showDismissButton={false}
        leftBarButtons={[{
          title: i18n('Cancel'),
          testID: 'compose-message.cancel',
          action: this.cancelCompose,
        }]}
        rightBarButtons={[
          {
            disabled: this.state.sendDisabled,
            title: i18n('Send'),
            testID: 'compose-message.send',
            action: this.sendMessage,
            style: 'done',
          },
          {
            image: Images.attachmentLarge,
            testID: 'compose-message.attach',
            action: this.editAttachments,
            accessibilityLabel: i18n('Edit attachments ({count})', { count: this.state.attachments.length }),
            badge: this.state.attachments.length > 0 && {
              text: i18n.number(this.state.attachments.length),
              backgroundColor: processColor('#008EE2'),
              textColor: processColor('white'),
            },
          },
        ]}
      >
        <View style={{ flex: 1 }}>
          <ModalOverlay text={i18n('Sending...')} visible={this.state.pending}/>
          <KeyboardAwareScrollView
            style={styles.compose}
            ref={e => { this.scrollView = e }}
            contentContainerStyle={{ flexGrow: 1, paddingBottom: 16 }}
          >
            { this.props.showCourseSelect &&
              <TouchableHighlight testID='compose.course-select' underlayColor='#fff' style={styles.wrapper} onPress={this.props.canSelectCourse ? this.selectCourse : undefined}>
                <View style={styles.courseSelect}>
                  <Text style={[styles.courseSelectText, this.state.contextName ? styles.courseSelectedText : undefined]}>
                    { this.state.contextName || i18n('Select a Course') }
                  </Text>
                  { this.props.canSelectCourse &&
                    <DisclosureIndicator />
                  }
                </View>
              </TouchableHighlight>
            }
            { Boolean(this.state.contextCode) &&
              <View style={[styles.wrapper, styles.toContainer]}>
                {this.state.recipients.length === 0 &&
                  <View testID='compose.recipients-placeholder' style={{ padding: 6, paddingLeft: 0, height: 54, justifyContent: 'center' }}>
                    <Text style={styles.courseSelectText}>{i18n('To')}</Text>
                  </View>
                }
                <View style={styles.tokenContainer}>
                  {this.state.recipients.map((r) => {
                    return (<AddressBookToken key={r.id} item={r} delete={this._deleteRecipient} />)
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
                style={[styles.cell, styles.courseSelectText, styles.courseSelectedText]}
                placeholderTextColor={colors.lightText}
                onChangeText={this._subjectChanged}
                editable={this.props.canEditSubject}
              />
            </View>
            { !this.props.onlySendIndividualMessages && !this.props.conversationID &&
              <RowWithSwitch
                border='bottom'
                title={i18n('Send individual message to each recipient')}
                onValueChange={this.toggleSendAll}
                value={this.state.sendToAll}
                identifier='compose-message.send-all-toggle'
              />
            }
            <View style={[styles.message, styles.messageWrapper]}>
              <AutoGrowingTextInput
                placeholder={i18n('Compose Message')}
                style={styles.cell}
                placeholderTextColor={colors.lightText}
                defaultHeight={54}
                onContentSizeChange={this.scrollToEnd}
                onChangeText={this._bodyChanged}
                testID='compose-message.body-text-input'
                extraHeight={20}
              />
            </View>
            {this.props.includedMessages &&
              <View testID='compose.forwarded-message' style={styles.forwardedMessage}>
                <Text style={styles.forwardedMessageTitle}>{i18n('Forwarded Message:')}</Text>
                <Text style={styles.forwardedMessageText}>{this.props.includedMessages[0].body}</Text>
              </View>
            }
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
    paddingTop: 10,
    paddingBottom: 40,
  },
  message: {
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
    flex: 1,
    flexWrap: 'wrap',
    paddingVertical: 8,
  },
  forwardedMessage: {
    paddingHorizontal: 16,
  },
  forwardedMessageTitle: {
    fontWeight: '500',
    marginBottom: 8,
  },
  forwardedMessageText: {
    fontWeight: '300',
  },
})

export function mapStateToProps (): any {
  return {}
}

const Connected = connect(mapStateToProps, Actions)(Compose)
export default (Connected: PureComponent<any, any>)
