// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
} from 'react-native'
import { Text } from '../../../common/text'
import Button from 'react-native-button'
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

  render () {
    const sub = this.props.submissionProps
    let name = this.props.anonymous
      ? (sub.groupID ? i18n('Group') : i18n('Student'))
      : sub.name
    return <View style={[this.props.style, styles.header]}>
      <View style={styles.profileContainer}>
        <View style={styles.avatar}><Avatar key={sub.userID} avatarURL={sub.avatarURL} userName={name} /></View>
        <View style={styles.nameContainer}>
          <Text style={styles.name} accessibilityTraits='header'>{name}</Text>
          <SubmissionStatus status={sub.status} />
        </View>
        <View style={styles.doneButton}>
          <Button onPress={this.props.closeModal} testID='header.navigation-done'>
            <View style={{ paddingLeft: 20 }}>
              <Text style={{ color: '#008EE2', fontSize: 18, fontWeight: '600' }}>
                {i18n('Done')}
              </Text>
            </View>
          </Button>
        </View>
      </View>
    </View>
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
    flex: 1,
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

type HeaderProps = RouterProps & HeaderDataProps
