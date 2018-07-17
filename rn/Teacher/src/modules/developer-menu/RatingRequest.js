//
// Copyright (C) 2018-present Instructure, Inc.
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

import * as React from 'react'
import {
  DatePickerIOS,
  NativeModules,
  ScrollView,
  StyleSheet,
  View,
} from 'react-native'

import Screen from '../../routing/Screen'
import { Text } from '../../common/text'
import RowWithDateInput from '../../common/components/rows/RowWithDateInput'
import RowWithSwitch from '../../common/components/rows/RowWithSwitch'
import RowWithTextInput from '../../common/components/rows/RowWithTextInput'
import RowSeparator from '../../common/components/rows/RowSeparator'
import { isStudent } from '../app/index'

type Props = {}

type State = {
  fakeRequest: number,
  lastRequestDate: number,
  lastRequestDateShown: boolean,
  launchCount: number,
  viewAssignmentDate: number,
  viewAssignmentDateShown: boolean,
  viewAssignmentCount: number,
}

export default class RatingRequest extends React.PureComponent<Props, State> {
  state = {
    fakeRequest: 0,
    lastRequestDate: 0,
    lastRequestDateShown: false,
    launchCount: 0,
    viewAssignmentDate: 0,
    viewAssignmentDateShown: false,
    viewAssignmentCount: 0,
  }

  interval: IntervalID

  componentDidMount () {
    const update = () => {
      NativeModules.AppStoreReview.getState().then(values =>
        this.setState(values)
      )
    }
    update()
    // poll so home then reopen reflects changes
    this.interval = setInterval(update, 1000)
  }

  componentWillUnmount () {
    clearInterval(this.interval)
  }

  setBothStates (key: string, value: number) {
    NativeModules.AppStoreReview.setState(key, value)
    this.setState({ [key]: value })
  }

  setFakeRequest = (value: boolean) => {
    this.setBothStates('fakeRequest', +value)
  }

  toggleLastRequestDate = () => {
    this.setState(({ lastRequestDateShown }) => ({
      lastRequestDateShown: !lastRequestDateShown,
    }))
  }

  setLastRequestDate = (value: Date) => {
    this.setBothStates('lastRequestDate', +value || 0)
  }

  removeLastRequestDate = () => {
    this.setBothStates('lastRequestDate', 0)
  }

  setLaunchCount = (text: string) => {
    this.setBothStates('launchCount', parseInt(text.trim(), 10) || 0)
  }

  toggleViewAssignmentDate = () => {
    this.setState(({ viewAssignmentDateShown }) => ({
      viewAssignmentDateShown: !viewAssignmentDateShown,
    }))
  }

  setViewAssignmentDate = (value: Date) => {
    this.setBothStates('viewAssignmentDate', +value || 0)
  }

  removeViewAssignmentDate = () => {
    this.setBothStates('viewAssignmentDate', 0)
  }

  setViewAssignmentCount = (text: string) => {
    this.setBothStates('viewAssignmentCount', parseInt(text.trim(), 10) || 0)
  }

  render () {
    const {
      fakeRequest,
      lastRequestDate,
      lastRequestDateShown,
      launchCount,
      viewAssignmentDate,
      viewAssignmentDateShown,
      viewAssignmentCount,
    } = this.state

    return (
      <Screen title='Manage Rating Request'>
        <ScrollView style={styles.mainContainer}>
          <RowSeparator />
          <RowWithSwitch
            title='Use Fake Prompt'
            value={Boolean(fakeRequest)}
            onValueChange={this.setFakeRequest}
          />
          <RowSeparator />
          <Text style={styles.paragraph}>
            Requests for App Store ratings are only prompted when it has been at
            least 30 days since the last request. Clearing this, or setting it
            to long ago is prerequisite to seeing a request.
          </Text>
          <RowSeparator />
          <RowWithDateInput
            title='Last Request'
            date={lastRequestDate ? new Date(lastRequestDate).toISOString() : null}
            selected={lastRequestDateShown}
            onPress={this.toggleLastRequestDate}
            showRemoveButton
            onRemoveDatePress={this.removeLastRequestDate}
          />
          { lastRequestDateShown &&
            <DatePickerIOS
              date={new Date(lastRequestDate || Date.now())}
              onDateChange={this.setLastRequestDate}
            />
          }
          <RowSeparator />
          { isStudent() ? (
            <View>
              <Text style={styles.paragraph}>
                Student requests a rating after 3 consecutive days of looking at
                an announcement, assignment, or discussion.
              </Text>
              <RowSeparator />
              <RowWithDateInput
                title='Last View'
                date={viewAssignmentDate ? new Date(viewAssignmentDate).toISOString() : null}
                selected={viewAssignmentDateShown}
                onPress={this.toggleViewAssignmentDate}
                showRemoveButton
                onRemoveDatePress={this.removeViewAssignmentDate}
              />
              { viewAssignmentDateShown &&
                <DatePickerIOS
                  date={new Date(viewAssignmentDate || Date.now())}
                  onDateChange={this.setViewAssignmentDate}
                />
              }
              <RowSeparator />
              <RowWithTextInput
                title='Consecutive Days'
                placeholder='0'
                keyboardType='numeric'
                value={String(viewAssignmentCount)}
                onChangeText={this.setViewAssignmentCount}
              />
              <RowSeparator />
            </View>
          ) : (
            <View>
              <Text style={styles.paragraph}>
                Teacher & Parent apps request a rating after 10 app launches.
              </Text>
              <RowSeparator />
              <RowWithTextInput
                title='Launches'
                placeholder='0'
                keyboardType='numeric'
                value={String(launchCount)}
                onChangeText={this.setLaunchCount}
              />
              <RowSeparator />
            </View>
          ) }
          <Text style={styles.paragraph}>
            Submitting an assignment, posting a discussion, announcement, or
            reply, and sending a message all trigger a rating request. Leaving
            the grades page after seeing a grade > 90% does too.
          </Text>
        </ScrollView>
      </Screen>
    )
  }
}

let styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  paragraph: {
    padding: global.style.defaultPadding,
  },
})
