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
  const master = require(`./citests/coverage-summary-master.json`)
  const pr = require(`./citests/coverage-summary.json`)
  const { fileMinCoverage, totalMinCoverage } = require('./config.json')
  const empty = { executableLines: 0, coveredLines: 0 }
  const files = Object.keys(pr).filter(path => (path !== 'total' &&
    (pr[path].coveredLines / pr[path].executableLines) < fileMinCoverage
  ))

  if (files.length > 0) {
    warn(`One or more files are below the minimum test coverage ${percent(fileMinCoverage)}`)
  }
  if (pr.total.coveredLines / pr.total.executableLines < totalMinCoverage) {
    warn(`The total test coverage is below the minimum ${percent(totalMinCoverage)}`)
  }
  markdown(`
    Coverage | New % | Master % | Delta
    -------- | ----- | -------- | -----
    **Canvas iOS** | ${coverageMarkdown(pr.total, master.total)}
    ${files.map(path =>
      `${path} | ${coverageMarkdown(pr[path], master[path] || empty)}`
    ).join('\n')}\n
  `.trim().replace(/\n\s+/g, '\n'))
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
