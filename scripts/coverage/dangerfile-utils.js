//
// Copyright (C) 2019-present Instructure, Inc.
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

exports.checkCoverage = checkCoverage
function checkCoverage () {
  let table = checkSchemeCoverage('Core')
  table += checkSchemeCoverage('Student')
  table += checkSchemeCoverage('Teacher')

  const master = require('../../rn/Teacher/coverage/coverage-summary-master.json')
  const pr = require('../../rn/Teacher/coverage/coverage-summary.json')
  table += checkCoverage('React Native', convertCoverage(master), convertCoverage(pr))
  markdown(`
    Coverage | New % | Master % | Delta
    -------- | ----- | -------- | -----
    ${table}
  `.trim().replace(/\n\s+/g, '\n'))
}

// Convert to `xcrun xccov view --json` format
function convertCoverage (jest) {
  const xccov = {}
  for (const key of Object.keys(jest)) {
    xccov[key] = {
      executableLines: jest[key].lines.total,
      coveredLines: jest[key].lines.covered,
    }
  }
  return xccov
}

function checkSchemeCoverage (scheme, masterCoverage, prCoverage) {
  const coverageFolder = `./${scheme.toLowerCase()}`
  const master = masterCoverage || require(`${coverageFolder}/coverage-summary-master.json`)
  const pr = prCoverage || require(`${coverageFolder}/coverage-summary.json`)

  const { fileMinCoverage, totalMinCoverage } = require('./config.json')
  const empty = { executableLines: 0, coveredLines: 0 }
  const files = Object.keys(pr).filter(path => (path !== 'total' &&
    (pr[path].coveredLines / pr[path].executableLines) < fileMinCoverage
  ))

  if (files.length > 0) {
    fail(`One or more files are below the minimum test coverage ${percent(fileMinCoverage)}`)
  }
  if (pr.total.coveredLines / pr.total.executableLines < totalMinCoverage) {
    fail(`The total test coverage is below the minimum ${percent(totalMinCoverage)}`)
  }
  return `**${scheme}** | ${coverageMarkdown(pr.total, master.total)}
    ${files.map(path =>
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
