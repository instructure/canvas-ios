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
    <SubTitle style={styles.textStyle}>Subtitle</SubTitle>
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
    Object.keys(colors).map(key => (
      <ColorStyle name={key} color={colors[key]} />
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
