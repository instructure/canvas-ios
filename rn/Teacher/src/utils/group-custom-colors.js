// @flow

import parseContextCode from './parse-context-code'

/*
 * Groups custom colors by their context type (course, account, group, etc).
 *
 * Example:
 *  const colors: CustomColors = {
 *    custom_colors: {
 *      course_1: '#fff',
 *      course_2: '#eee',
 *      account_1: '#ddd',
 *    }
 *  }
 *  groupCustomColors(colors)
 *
 * Result will be:
 *  {
 *    custom_colors: {
 *      course: {
 *        '1': '#fff',
 *        '2': '#eee',
 *      },
 *      account: {
 *        '1': '#ddd',
 *      },
 *    }
 *  }
 */
export default function groupCustomColors (colors: CustomColors): { [string]: { [string]: { [string]: string } } } {
  let result = {}
  for (const group in colors) {
    result[group] = {}
    for (const contextCode in colors[group]) {
      const parsed = parseContextCode(contextCode)
      result[group][parsed.type] = result[group][parsed.type] || {}
      result[group][parsed.type][parsed.id] = colors[group][contextCode]
    }
  }
  return result
}
