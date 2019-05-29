#!/usr/bin/env node
/*
Converts a SVG to a PDF file.

Depends on node
 brew install node

Run this script from the repo root directory
 yarn svg2pdf file.svg out.pdf 24x24
*/

const fs = require('fs')
const jsdom = require('jsdom').JSDOM
const PDFDocument = require('pdfkit')

if (require.main == module) {
  const [ , , svg, pdf, size ] = process.argv
  convert(svg, pdf, size ? size.split(/\D+/).map(n => +n) : null)
}

function convert(svgPath, pdfPath, size) {
  const svg = new jsdom(fs.readFileSync(svgPath, 'utf8')).window.document.querySelector('svg')
  const pdf = new PDFDocument({ autoFirstPage: false })
  pdf._id = Buffer.from([ 0 ]) // consistent, small id
  pdf.pipe(fs.createWriteStream(pdfPath))
  pdf.info = {} // remove metadata
  const viewBox = (
    svg.getAttribute('viewBox')
    || `0 0 ${+svg.getAttribute('width')} ${+svg.getAttribute('height')}`
  ).split(/\s+/).map(n => +n)
  pdf.addPage({ size: size || viewBox.slice(2) })
  if (size) {
    pdf.scale(Math.min(size[0] / viewBox[2], size[1] / viewBox[3]))
  }
  for (const path of svg.querySelectorAll('path')) {
    pdf
      .path(path.getAttribute('d').trim())
      .fill(path.getAttribute('fill-rule') || 'evenodd')
  }
  pdf.end()
}

module.exports = convert
