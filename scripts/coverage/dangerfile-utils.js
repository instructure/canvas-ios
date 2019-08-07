//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

exports.checkCoverage = checkCoverage
function checkCoverage () {
  markdown(`
    Coverage | New % | Master % | Delta
    -------- | ----- | -------- | -----
    ${checkSchemeCoverage(
      'Canvas iOS',
      require(`./citests/coverage-summary-master.json`),
      require(`./citests/coverage-summary.json`)
    )}${checkSchemeCoverage(
      'React Native',
      convertCoverage(require('./react-native/coverage-summary-master.json')),
      convertCoverage(require('./react-native/coverage-summary.json'))
    )}
  `.trim().replace(/\n\s+/g, '\n'))
}

// Convert to `xcrun xccov view --json` format
function convertCoverage (jest) {
  const xccov = {}
  for (const key of Object.keys(jest)) {
    const path = key.replace(/^.*\/rn\//, 'rn/')
    xccov[path] = {
      executableLines: jest[key].lines.total,
      coveredLines: jest[key].lines.covered,
    }
  }
  return xccov
}

function checkSchemeCoverage (scheme, master, pr) {
  const { fileMinCoverage, totalMinCoverage } = require('./config.json')
  const empty = { executableLines: 0, coveredLines: 0 }
  const files = Object.keys(pr).filter(path => (path !== 'total' &&
    (pr[path].coveredLines / pr[path].executableLines) < fileMinCoverage
  ))

  if (files.length > 0) {
    fail(`One or more files in ${scheme} are below the minimum test coverage ${percent(fileMinCoverage)}`)
  }
  if (pr.total.coveredLines / pr.total.executableLines < totalMinCoverage) {
    fail(`The total test coverage in ${scheme} is below the minimum ${percent(totalMinCoverage)}`)
  }
  return `**${scheme}** | ${coverageMarkdown(pr.total, master.total)}
    ${files.slice(0, 10).map(path =>
      `${path} | ${coverageMarkdown(pr[path], master[path] || empty)}`
    ).join('\n')}\n`
}

function coverageMarkdown (pr, master) {
  const prRatio = pr.coveredLines / pr.executableLines
  const masterRatio = master.coveredLines / master.executableLines
  return [ percent(prRatio), percent(masterRatio), percent(prRatio - masterRatio) ].join(' | ')
}

function percent(num) {
  if (!isFinite(num)) { return '--' }
  return num.toLocaleString('en', { style: 'percent', maximumFractionDigits: 2 })
}
