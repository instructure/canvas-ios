// @flow

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  Image,
  TouchableHighlight,
  PickerIOS,
  LayoutAnimation,
} from 'react-native'
import { Text } from '../../../common/text'
import Images from '../../../images'
import Button from 'react-native-button'
import i18n from 'format-message'
import type {
  SubmissionDataProps,
} from '../../submissions/list/submission-prop-types'
import SubmissionStatus from '../../submissions/list/SubmissionStatus'
import { formattedDueDate } from '../../../common/formatters'
import SpeedGraderActions from '../actions'
import Avatar from '../../../common/components/Avatar'

var PickerItemIOS = PickerIOS.Item

export class Header extends Component {
  props: HeaderProps
  state: State

  constructor (props: HeaderProps) {
    super(props)

    this.state = {
      showingPicker: false,
    }
  }

  _togglePicker = () => {
    LayoutAnimation.easeInEaseOut()
    const showingPicker = !this.state.showingPicker
    this.setState({ showingPicker })
  }

  changeSelectedSubmission = (index: number) => {
    if (this.props.submissionID) {
      this.props.selectSubmissionFromHistory(this.props.submissionID, index)
      this._togglePicker()
    }
  }

  hasSubmission () {
    let stati = ['none', 'missing']
    return !stati.includes(this.props.submissionProps.status) && !!this.props.submissionProps.submission
  }

  renderSubmissionHistory () {
    const submission = this.props.submissionProps.submission
    if (!this.hasSubmission()) return <View style={[styles.submissionHistoryContainer, styles.noSub]} />

    if (submission && submission.submission_history &&
      submission.submission_history.length > 1) {
      let selected = submission
      let index = this.props.selectedIndex
      if (index != null) {
        selected = submission.submission_history[index]
      } else {
        index = submission.submission_history.length - 1
      }
      return <View>
        <TouchableHighlight
          underlayColor="#eee"
          onPress={this._togglePicker}
          testID='header.toggle-submission_history-picker'
          accessibilityTraits='button'
        >
          <View style={styles.submissionHistoryContainer}>
            <Text style={[styles.submissionDate, this.state.showingPicker && styles.selecting]}>
              {formattedDueDate(new Date(selected.submitted_at || ''))}
            </Text>
            <Image source={Images.pickerArrow} style={[{ alignSelf: 'center' }, this.state.showingPicker && styles.arrowSelecting]} />
          </View>
        </TouchableHighlight>
        { this.state.showingPicker &&
          <PickerIOS
            selectedValue={index}
            onValueChange={this.changeSelectedSubmission}
            testID='header.picker'
          >
            {submission.submission_history.map((sub, idx) => (
              <PickerItemIOS
                key={sub.id}
                value={idx}
                label={formattedDueDate(new Date(sub.submitted_at || ''))}
              />
            ))}
          </PickerIOS>
        }
      </View>
    } else {
      if (!submission) return <View style={[styles.submissionHistoryContainer, styles.noSub]} />
      return <View style={styles.submissionHistoryContainer}>
        <Text style={styles.submissionDate}>
          {formattedDueDate(new Date(submission.submitted_at || ''))}
        </Text>
      </View>
    }
  }

  render () {
    const sub = this.props.submissionProps
    let name = this.props.anonymous
      ? (sub.groupID ? i18n('Group') : i18n('Student'))
      : sub.name
    return <View style={styles.header}>
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
      {this.renderSubmissionHistory()}
    </View>
  }
}

const styles = StyleSheet.create({
  header: {
    marginBottom: 1,
    backgroundColor: 'white',
  },
  profileContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 16,
  },
  noSub: {
    paddingBottom: 21,
  },
  settingsButton: {
    width: 20,
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
  submissionHistoryContainer: {
    marginTop: 16,
    marginLeft: 16,
    marginRight: 16,
    borderBottomColor: '#D8D8D8',
    borderBottomWidth: 1,
    borderStyle: 'solid',
    paddingBottom: 4,
    flex: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  submissionDate: {
    color: '#8B969E',
    fontSize: 14,
    fontWeight: '500',
  },
  selecting: {
    color: '#008EE2',
  },
  arrowSelecting: {
    tintColor: '#008EE2',
    transform: [
     { rotate: '180deg' },
    ],
  },
})

export function mapStateToProps (state: AppState, ownProps: RouterProps): HeaderDataProps {
  let anonymous = state.entities.assignments[ownProps.assignmentID].anonymousGradingOn
  if (!ownProps.submissionID) {
    return {
      selectedIndex: null,
      anonymous,
    }
  }

  return {
    selectedIndex: state.entities.submissions[ownProps.submissionID].selectedIndex,
    anonymous,
  }
}

let Connected = connect(mapStateToProps, SpeedGraderActions)(Header)
export default (Connected: any)

type RouterProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
  submissionID: ?string,
  submissionProps: SubmissionDataProps,
  closeModal: Function,
}

type State = {
  showingPicker: boolean,
}

type HeaderDataProps = {
  selectedIndex: ?number,
  anonymous: boolean,
}

type HeaderActionProps = {
  selectSubmissionFromHistory: Function,
}

type HeaderProps = RouterProps & HeaderDataProps & HeaderActionProps
