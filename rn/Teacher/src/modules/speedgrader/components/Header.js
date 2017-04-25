// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  Image,
} from 'react-native'
import { Text } from '../../../common/text'
import Images from '../../../images'
import Button from 'react-native-button'
import i18n from 'format-message'
import type {
  SubmissionDataProps,
} from '../../submissions/list/submission-prop-types'
import SubmissionStatus from '../../submissions/list/SubmissionStatus'

export class Header extends Component {
  props: HeaderProps

  renderSubmissionHistory () {
    if (this.props.submissionProps.status === 'none') return null
    return <View style={styles.submissionHistoryContainer}>
      <Text style={styles.submissionDate}>{this.props.submissionProps.submission && this.props.submissionProps.submission.submitted_at}</Text>
    </View>
  }

  render (): React.Element<*> {
    const sub = this.props.submissionProps
    return <View style={styles.header}>
      <View style={styles.profileContainer}>
        <View><Image source={{ uri: sub.avatarURL }} style={styles.avatarImage} /></View>
        <View style={styles.nameContainer}>
          <Text style={styles.name}>{sub.name}</Text>
          <SubmissionStatus status={sub.status} />
        </View>
        <View>
          <Button style={styles.settingsButton} onPress={() => {}} testID='header.settings'>
            <View>
              <Image source={Images.course.settings} style={styles.navButtonImage} />
            </View>
          </Button>
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
      {this.renderSubmissionHistory()}
    </View>
  }
}

const styles = StyleSheet.create({
  header: {
    height: 92,
    flex: 0,
    flexDirection: 'column',
  },
  profileContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 16,
  },
  settingsButton: {
    width: 20,
  },
  navButtonImage: {
    resizeMode: 'contain',
    tintColor: '#008EE2',
  },
  avatarImage: {
    width: 40,
    height: 40,
    borderRadius: 20,
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
  statusLate: {
    color: '#FC5E13',
  },
  doneButton: {
    marginRight: 12,
  },
  submissionHistoryContainer: {
    marginTop: 16,
    marginLeft: 16,
    marginRight: 16,
    borderBottomColor: '#D8D8D8',
    borderBottomWidth: 1,
    borderStyle: 'solid',
    paddingBottom: 4,
  },
  submissionDate: {
    color: '#8B969E',
    fontSize: 14,
    fontWeight: '500',
  },
})

let Connected = connect(null, { })(Header)
export default (Connected: any)

type HeaderProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
  submissionID: ?string,
  submissionProps: SubmissionDataProps,
  closeModal: Function,
}
