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
import { View, StyleSheet } from 'react-native'
import { Heading2 } from '../text'
import { parseErrorMessage } from '../../redux/middleware/error-handler'
import { LinkButton } from '../buttons'
import i18n from 'format-message'

export type ErrorViewProps = {
  error: any,
  onRetry: ?Function, // If supplied, a retry button will show up underneath the error message
}

export default class ErrorView extends PureComponent<any, ErrorViewProps> {
  render () {
    const message = parseErrorMessage(this.props.error)
    return <View style={styles.container}>
      <Heading2 style={styles.message}>{message}</Heading2>
      { this.props.onRetry && <LinkButton onPress={this.props.onRetry}>{i18n('Retry')}</LinkButton>}
    </View>
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: global.style.defaultPadding,
  },
  message: {
    textAlign: 'center',
    marginBottom: global.style.defaultPadding / 2,
  },
})
