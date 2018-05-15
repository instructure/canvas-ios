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

import React from 'react'
import {
  StyleSheet,
  View,
  ScrollView,
} from 'react-native'
import Screen from '../routing/Screen'
import colors from './colors'

import {
  Heading1,
  Heading2,
  Title,
  SubTitle,
  Paragraph,
} from './text'

const StyleRow = ({ title, children, contentStyle }: {
  title: string,
  children?: *,
  contentStyle?: number,
}) => (
  <View style={styles.styleRow}>
    <View style={styles.rowTitle}>
      <Title>{title}</Title>
    </View>
    <View style={contentStyle}>
      {children}
    </View>
  </View>
)

const TextStyles = () => (
  <StyleRow title='Text'>
    <Heading1 style={styles.textStyle}>Heading1</Heading1>
    <Heading2 style={styles.textStyle}>Heading2</Heading2>
    <Title style={styles.textStyle}>Title</Title>
    <SubTitle style={styles.textStyle}>SubTitle</SubTitle>
    <Paragraph style={styles.textStyle}>Paragraph</Paragraph>
  </StyleRow>
)

const ColorStyle = ({ name, color }: { name: string, color: string }) => (
  <View style={styles.colorCard}>
    <View style={[styles.color, { backgroundColor: color }]} />
    <Title style={{ fontSize: 10 }}>{name}</Title>
    <SubTitle>{color}</SubTitle>
  </View>
)

const ColorStyles = () => (
  <StyleRow
    title='Colors'
    contentStyle={styles.colorContent}>{
      Object.keys(colors).filter(key => key !== 'statusBarStyle').map(key => (
        <ColorStyle key={key} name={key} color={colors[key]} />
      ))
    }</StyleRow>
)

export default () => (
  <Screen>
    <ScrollView>
      <TextStyles />
      <ColorStyles />
    </ScrollView>
  </Screen>
)

const styles = StyleSheet.create({
  styleRow: {
    flexDirection: 'row',
    margin: global.style.defaultPadding,
  },
  rowTitle: {
    width: '16%',
  },
  textStyle: {
    paddingBottom: 8,
  },
  colorContent: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  colorCard: {
    paddingBottom: 12,
  },
  color: {
    width: 80,
    height: 80,
    marginRight: 20,
    borderColor: colors.seperatorColor,
    borderWidth: StyleSheet.hairlineWidth,
  },
})
