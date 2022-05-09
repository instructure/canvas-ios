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

import React, { PureComponent } from 'react'
import {
  View,
  TextInput,
  TouchableHighlight,
  TouchableOpacity,
  Image,
  LayoutAnimation,
  NativeModules,
  Alert,
  processColor,
  AccessibilityInfo,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import Images from '../../images'
import Actions from './actions'
import Screen from '../../routing/Screen'
import { colors, createStyleSheet } from '../../common/stylesheet'
import DisclosureIndicator from '../../common/components/DisclosureIndicator'
import RowWithSwitch from '../../common/components/rows/RowWithSwitch'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import ModalOverlay from '../../common/components/ModalOverlay'
import AddressBookToken from './components/AddressBookToken'
import { createConversation, addMessage, isAbort } from '../../canvas-api'
import { Text } from '../../common/text'

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
  instructorQuestion?: boolean,
}

type ComposeState = {
  sendDisabled: boolean,
  sendToAll: boolean,
  recipients: AddressBookResult[],
  contextId: ?string,
  contextCode: ?string,
  contextName: ?string,
  body: ?string,
  subject: ?string,
  pending: boolean,
  attachments: Attachment[],
}

export class Compose extends PureComponent<ComposeProps & OwnProps, ComposeState> {
  scrollView: ?KeyboardAwareScrollView

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
    contextId: null,
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
        selectedCourseId: this.state.contextId,
        onSelect: (course: Course) => {
          this.props.navigator.pop()
          const contextId = course.id
          const contextName = course.name
          const contextCode = `course_${course.id}`
          let recipients = []
          if (this.props.instructorQuestion) {
            const teachers = { id: `course_${course.id}_teachers`, name: i18n('Teachers') }
            recipients = [teachers]
          }
          this.setStateAndUpdate({ contextId, contextName, contextCode, recipients })
        },
      }
    )
  }

  mustSendAll () {
    return this.state.recipients.reduce((count: number, result: AddressBookResult) => (
      count + (result.user_count || 1)
    ), 0) >= 100
  }

  sendMessage = () => {
    AccessibilityInfo.announceForAccessibility(i18n('Sending message'))
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

    if (this.mustSendAll() || state.sendToAll) {
      convo.bulk_message = 1
    }

    this.setState({ pending: true })
    const promise = this.props.conversationID ? addMessage(this.props.conversationID, convo) : createConversation(convo)
    promise.then((response) => {
      AccessibilityInfo.announceForAccessibility(i18n('Message sent'))
      this.props.refreshInboxSent()
      this.props.navigator.dismissAllModals()
        .then(() => NativeModules.AppStoreReview.handleSuccessfulSubmit())
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
        navBarStyle='modal'
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
            image: Images.paperclip,
            testID: 'compose-message.attach',
            action: this.editAttachments,
            accessibilityLabel: i18n('Edit attachments ({count})', { count: this.state.attachments.length }),
            badge: this.state.attachments.length > 0 && {
              text: i18n.number(this.state.attachments.length),
              backgroundColor: processColor(colors.textInfo),
              textColor: processColor(colors.white),
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
            { Boolean(this.props.showCourseSelect) &&
              <TouchableHighlight
                testID='compose.course-select'
                underlayColor='#ffffff00'
                style={styles.wrapper}
                onPress={this.props.canSelectCourse ? this.selectCourse : undefined}
                accessibilityLabel={i18n('Select a Course')}
                accessibilityTraits={['button']}
                accessibilityValue={{ text: this.state.contextName }}
                accessible={this.props.canSelectCourse}
              >
                <View style={styles.courseSelect}>
                  <Text style={[styles.courseSelectText, this.state.contextName ? styles.courseSelectedText : undefined]}>
                    { this.state.contextName || i18n('Select a Course') }
                  </Text>
                  { Boolean(this.props.canSelectCourse) &&
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
                    return (
                      <AddressBookToken
                        key={r.id}
                        item={r}
                        delete={this._deleteRecipient}
                        canDelete={!this.props.instructorQuestion}
                      />
                    )
                  })}
                </View>
                { Boolean(this.props.canAddRecipients) &&
                  <TouchableOpacity testID='compose.add-recipient' onPress={this._openAddressBook} style={{ height: 54, justifyContent: 'center' }} accessibilityTraits={['button']} accessibilityLabel={i18n('Add recipient')}>
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
                placeholderTextColor={colors.textDark}
                onChangeText={this._subjectChanged}
                editable={this.props.canEditSubject}
                testID='compose-message.subject-text-input'
                accessibilityLabel={i18n('Subject')}
              />
            </View>
            { !this.props.onlySendIndividualMessages && !this.props.conversationID && !this.props.instructorQuestion &&
              <RowWithSwitch
                border='bottom'
                title={i18n('Send individual message to each recipient')}
                onValueChange={this.toggleSendAll}
                value={this.mustSendAll() || this.state.sendToAll}
                identifier='compose-message.send-all-toggle'
              />
            }
            <TextInput
              placeholder={i18n('Compose Message')}
              style={styles.body}
              placeholderTextColor={colors.textDark}
              onChangeText={this._bodyChanged}
              testID='compose-message.body-text-input'
              multiline={true}
              scrollEnabled={false}
              accessibilityLabel={i18n('Message body')}
            />
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

const k5Font = 'BalsamiqSans-Regular'
const regularFont = 'Lato-Regular'
const styles = createStyleSheet((colors, vars) => ({
  compose: {
    flex: 1,
  },
  cell: {
    height: 54,
    fontSize: 16,
    lineHeight: 19,
    color: colors.textDarkest,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  body: {
    fontSize: 16,
    lineHeight: vars.isK5Enabled ? 19 : 24, // 24 is a manually calculated 'condensed' height for 16 point font
    color: colors.textDarkest,
    paddingTop: 10,
    paddingBottom: vars.padding / 2,
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    fontFamily: vars.isK5Enabled ? k5Font : regularFont,
  },
  wrapper: {
    borderBottomColor: colors.borderMedium,
    borderBottomWidth: vars.hairlineWidth,
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
    color: colors.textDark,
  },
  courseSelectedText: {
    color: colors.textDarkest,
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
}))

export function mapStateToProps (): any {
  return {}
}

const Connected = connect(mapStateToProps, Actions)(Compose)
export default (Connected: PureComponent<any, any>)
