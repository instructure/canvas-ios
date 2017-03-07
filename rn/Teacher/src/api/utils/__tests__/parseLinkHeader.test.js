/* @flow */

import parseLinkHeader from '../parseLinkHeader'

test('null returns null', () => {
  expect(parseLinkHeader(null)).toBeNull()
})

test('one link with semicolon', () => {
  const link = '<https://example.com/items?page=2>; rel=\'current\';'
  const expected = {
    current: {
      url: 'https://example.com/items?page=2',
      rel: 'current',
    },
  }
  const result = parseLinkHeader(link) || {}
  expect(result).toEqual(expected)
})

test('one link without semicolon', () => {
  const link = '<https://example.com/items?page=2>; rel=\'current\''
  const expected = {
    current: {
      url: 'https://example.com/items?page=2',
      rel: 'current',
    },
  }
  const result = parseLinkHeader(link) || {}
  expect(result).toEqual(expected)
})

test('multiple links', () => {
  const link = '<https://example.com/items?page=1&per_page=1>; rel="current",\
         <https://example.com/items?page=2&per_page=1>; rel="next",\
         <https://example.com/items?page=1&per_page=1>; rel="first",\
         <https://example.com/items?page=4&per_page=1>; rel="last"'
  const expected = {
    next: {
      url: 'https://example.com/items?page=2&per_page=1',
      rel: 'next',
    },
    current: {
      url: 'https://example.com/items?page=1&per_page=1',
      rel: 'current',
    },
    first: {
      url: 'https://example.com/items?page=1&per_page=1',
      rel: 'first',
    },
    last: {
      url: 'https://example.com/items?page=4&per_page=1',
      rel: 'last',
    },
  }

  const result = parseLinkHeader(link)
  expect(result).toEqual(expected)
})

test('malformed links', () => {
  let link = 'https://example.com/items?page=1&per_page=1; rel="current"'
  expect(parseLinkHeader(link)).toBeNull()

  link = '<https://example.com/items?page=1&per_page=1>'
  expect(parseLinkHeader(link)).toBeNull()

  link = '<https://example.com/items?page=1&per_page=1>; rel='
  expect(parseLinkHeader(link)).toBeNull()

  link = '<https://example.com/items?page=1&per_page=1>; ref='
  expect(parseLinkHeader(link)).toBeNull()
})
