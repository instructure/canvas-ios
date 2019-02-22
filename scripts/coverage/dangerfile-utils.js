function checkCoverage (scheme, masterCoverage, prCoverage) {
  const coverageFolder = `./${scheme.toLowerCase()}`
  const master = masterCoverage || require(`${coverageFolder}/coverage-summary-master.json`)
  const pr = prCoverage || require(`${coverageFolder}/coverage-summary.json`)

  const { fileMinCoverage, totalMinCoverage } = require('./config.json')
  const empty = { executableLines: 0, coveredLines: 0 }
  const files = Object.keys(pr).filter(path => (path !== 'total' &&
    (pr[path].coveredLines / pr[path].executableLines) < fileMinCoverage
  ))
  markdown(`
    Coverage | New % | Master % | Delta
    -------- | ----- | -------- | -----
    **${scheme}** | ${coverageMarkdown(pr.total, master.total)}
    ${files.map(path =>
      `${path} | ${coverageMarkdown(pr[path], master[path] || empty)}`
    ).join('\n')}
  `.trim().replace(/\n\s+/g, '\n'))

  if (files.length > 0) {
    fail(`One or more files are below the minimum test coverage ${percent(fileMinCoverage)}`)
  }
  if (pr.total.coveredLines / pr.total.executableLines < totalMinCoverage) {
    fail(`The total test coverage is below the minimum ${percent(totalMinCoverage)}`)
  }
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

module.exports = {
  checkCoverage,
}
