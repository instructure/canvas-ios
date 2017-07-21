// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  TouchableHighlight,
} from 'react-native'
import { Text } from '../../../common/text'
import i18n from 'format-message'
import type {
  SubmissionDataProps,
} from '../../submissions/list/submission-prop-types'
import SubmissionStatus from '../../submissions/list/SubmissionStatus'
import Avatar from '../../../common/components/Avatar'

export class Header extends Component {
  props: HeaderProps
  state: State

  constructor (props: HeaderProps) {
    super(props)

    this.state = {
      showingPicker: false,
    }
  }

  renderDoneButton () {
    return (
      <View style={styles.doneButton}>
          <TouchableHighlight onPress={this.props.closeModal} underlayColor='white' testID='header.navigation-done'>
            <View style={{ paddingLeft: 20 }}>
              <Text style={{ color: '#008EE2', fontSize: 18, fontWeight: '600' }}>
                {i18n('Done')}
              </Text>
            </View>
          </TouchableHighlight>
        </View>
    )
  }

  renderGroupProfile () {
    const sub = this.props.submissionProps
    let name = this.props.anonymous
      ? (sub.groupID ? i18n('Group') : i18n('Student'))
      : sub.name

    let avatarURL = this.props.anonymous
      ? ''
      : sub.avatarURL

    if (sub.groupID && !this.props.anonymous) {
      return (
        <View style={styles.profileContainer}>
          <View style={{ flex: 1 }}>
            <View style={styles.innerRowContainer}>
              <TouchableHighlight
                onPress={this.showGroup}
                underlayColor='white'
                testID={'header.groupList.button'}>
                  <View style={styles.innerRowContainer}>
                    <View style={styles.avatar}>
                      <Avatar key={sub.userID} avatarURL={avatarURL} userName={name} />
                    </View>
                    <View style={styles.nameContainer}>
                      <Text style={styles.name} accessibilityTraits='header'>{name}</Text>
                      <SubmissionStatus status={sub.status} />
                    </View>
                  </View>
              </TouchableHighlight>
            </View>
          </View>
          {this.renderDoneButton()}
        </View>
      )
    } else {
      return (
        <View style={styles.profileContainer}>
          <View style={styles.avatar}><Avatar key={sub.userID} avatarURL={avatarURL} userName={name} /></View>
          <View style={[styles.nameContainer, { flex: 1 }]}>
            <Text style={styles.name} accessibilityTraits='header'>{name}</Text>
            <SubmissionStatus status={sub.status} />
          </View>
          {this.renderDoneButton()}
        </View>
      )
    }
  }

  render () {
    return (
      <View style={[this.props.style, styles.header]}>
        {this.renderGroupProfile()}
      </View>
    )
  }

  showGroup = () => {
    this.props.navigator.show(`/groups/${this.props.submissionProps.groupID}/users`, { modal: true })
  }
}

const styles = StyleSheet.create({
  header: {
    backgroundColor: 'white',
  },
  profileContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 16,
  },
  innerRowContainer: {
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
  },
  navButtonImage: {
    resizeMode: 'contain',
    tintColor: '#008EE2',
  },
  avatar: {
    width: 40,
    height: 40,
    marginLeft: 16,
  },
  nameContainer: {
    flexDirection: 'column',
    justifyContent: 'space-between',
    marginLeft: 12,
  },
  name: {
    fontSize: 16,
    fontWeight: '600',
  },
  status: {
    fontSize: 14,
  },
  doneButton: {
    backgroundColor: 'white',
    marginRight: 12,
  },
})

export function mapStateToProps (state: AppState, ownProps: RouterProps): HeaderDataProps {
  let anonymous = state.entities.assignments[ownProps.assignmentID].anonymousGradingOn
  return {
    anonymous,
  }
}

let Connected = connect(mapStateToProps)(Header)
export default (Connected: any)

type RouterProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
  submissionID: ?string,
  submissionProps: SubmissionDataProps,
  closeModal: Function,
  style?: Object,
}

type State = {
  showingPicker: boolean,
}

type HeaderDataProps = {
  anonymous: boolean,
}

type HeaderProps = RouterProps & HeaderDataProps & { navigator: Navigator }
