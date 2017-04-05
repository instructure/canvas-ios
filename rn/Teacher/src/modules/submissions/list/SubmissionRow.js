// @flow

import React from 'react'
import {
  View,
  StyleSheet,
  TouchableHighlight,
  Image,
  Text,
} from 'react-native'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'
import Token from '../../../common/components/Token'
import i18n from 'format-message'
import type {
  GradeProp,
  SubmissionProp,
  SubmissionStatusProp,
} from './submission-prop-types'
import colors from '../../../common/colors'

type RowProps = {
  +testID: string,
  +onPress?: () => void,
  +children?: Array<any>,
  +disclosure?: boolean,

}
const Row = ({ onPress, testID, children, disclosure }: RowProps): * => {
  return (
    <View style={styles.row}>
      <TouchableHighlight style={styles.touchableHighlight} onPress={onPress} testID={testID}>
        <View style={styles.container}>
          {children}
          {disclosure ? <DisclosureIndicator /> : undefined}
        </View>
      </TouchableHighlight>
    </View>
  )
}

const SubmissionStatus = ({ status }: { status: SubmissionStatusProp }): * => {
  let color: string = '#8B969E' // none
  let title: string = i18n({
    default: 'No submission yet',
    description: 'No submission from the student for the given assignment',
  })

  switch (status) {
    case 'late':
      color = '#FC5E13'
      title = i18n({
        default: 'Late',
        description: 'Assignment was turned in late',
      })
      break
    case 'missing':
      color = '#EE0612'
      title = i18n({
        default: 'Missing',
        description: 'The assignment has not been turned in',
      })
      break
    case 'submitted':
      color = '#07AF1F'
      title = i18n({
        default: 'Submitted',
        description: 'The assignment has been turned in',
      })
      break
  }

  return <Text style={[styles.statusText, { color }]}>{title}</Text>
}

const Grade = ({ grade }: {grade: ?GradeProp}): * => {
  if (!grade) {
    return null
  }

  const ungraded = i18n({
    default: 'ungraded',
    description: 'Label for ungraded assignment submission',
  })

  return grade === 'ungraded'
    ? <Token style={{ alignSelf: 'center' }} color={ colors.primaryButton }>{ ungraded }</Token>
    : <Text style={[ styles.gradeText, { alignSelf: 'center' } ]}>{ grade }</Text>
}

const SubmissionRow = ({ userID, onPress, avatarURL, name, status, grade }: SubmissionProp): * => {
  return (
    <Row disclosure testID={`submission-${userID}`} onPress={onPress(userID)}>
      <Image source={{ uri: avatarURL }} style={styles.avatar} />
      <View style={styles.textContainer}>
        <Text
          style={styles.title}
          ellipsizeMode='tail'
          numberOfLines={2}>{name}</Text>
        <SubmissionStatus status={status} />
      </View>
      <Grade grade={grade} />
    </Row>
  )
}

export default SubmissionRow

const styles = StyleSheet.create({
  row: {
    flex: 1,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
  },
  touchableHighlight: {
    flex: 1,
  },
  container: {
    flex: 1,
    backgroundColor: 'white',
    alignItems: 'flex-start',
    flexDirection: 'row',
    paddingTop: 10,
    paddingBottom: 10,
    paddingLeft: 16,
    paddingRight: 16,
  },
  textContainer: {
    flex: 1,
    paddingLeft: 8,
  },
  title: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#2D3B45',
  },
  statusText: {
    fontSize: 14,
    paddingTop: 2,
  },
  gradeText: {
    fontSize: 14,
    color: colors.primaryButton,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignSelf: 'center',
  },
})
