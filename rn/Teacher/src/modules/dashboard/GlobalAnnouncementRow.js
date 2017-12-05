// @flow

import React from 'react'
import {
  View,
  StyleSheet,
  Image,
} from 'react-native'
import DashboardContent from './DashboardContent'
import Images from '../../images'
import {
  Text,
  SubTitle,
} from '../../common/text'
import WebContainer from '../../common/components/WebContainer'
import i18n from 'format-message'

export type GlobalAnnouncementProps = {
  title: string,
  description: string,
  color: string,
  style?: any,
}

type State = {
  collapsed: boolean,
}

export default class GlobalAnnouncementRow extends React.Component<GlobalAnnouncementProps, State> {

  constructor (props: GlobalAnnouncementProps) {
    super(props)
    this.state = { collapsed: true }
  }

  render () {
    return (
      <DashboardContent
        style={this.props.style}
        contentStyle={[styles.rowContent, { borderColor: this.props.color, borderWidth: 1 }]}
      >
        <View style={[styles.iconContainer, { backgroundColor: this.props.color }]}>
          <Image source={Images.dashboard.announcement} style={styles.icon} />
        </View>
        <View style={styles.announcementDetails}>
          <Text style={styles.title}>{this.props.title}</Text>
          {
            this.state.collapsed
              ? <SubTitle>{i18n('Tap to view announcement')}</SubTitle>
              : <WebContainer />
          }
        </View>
      </DashboardContent>
    )
  }
}

const styles = StyleSheet.create({
  icon: {
    tintColor: 'white',
    marginTop: 15.5,
  },
  rowContent: {
    flexDirection: 'row',
  },
  iconContainer: {
    width: 40,
    alignItems: 'center',
  },
  announcementDetails: {
    margin: 8,
  },
  title: {
    fontWeight: '600',
  },
})
