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

const content = window.content = document.querySelector('#content')
const editor = window.editor = {
    isDragging: false,
    currentSelection: null,
    currentEditingImage: null,
    currentEditingLink: null,
    enabledItems: {},

    backupRange () {
        const selection = getSelection()
        const range = selection.rangeCount > 0 ? selection.getRangeAt(0) : document.createRange()
        editor.currentSelection = {
            startContainer: range.startContainer,
            startOffset: range.startOffset,
            endContainer: range.endContainer,
            endOffset: range.endOffset,
        }
    },

    restoreRange () {
        const selection = getSelection()
        selection.removeAllRanges()
        const range = document.createRange()
        range.setStart(editor.currentSelection.startContainer, editor.currentSelection.startOffset)
        range.setEnd(editor.currentSelection.endContainer, editor.currentSelection.endOffset)
        selection.addRange(range)
    },

    getSelectedNode () {
        const selection = getSelection()
        let node = selection.focusNode
        return node && (node.nodeName == '#text' ? node.parentNode : node)
    },

    execCommand (command, value = null) {
        document.execCommand('styleWithCSS', false, 'foreColor' === command)
        document.execCommand(command, false, value)
        editor.postState()
    },

    updateLink (href, text) {
        editor.restoreRange()
        if (editor.currentEditingLink) {
            editor.currentEditingLink.href = href
            editor.currentEditingLink.textContent = text
        } else if (getSelection().toString() == text) {
            document.execCommand('createLink', false, href)
        } else {
            document.execCommand('insertHTML', false, `<a href="${escapeHTML(href)}">${escapeHTML(text)}</a>`)
        }
        editor.postState()
        content.focus()
    },

    updateImage (src, alt) {
        editor.restoreRange()
        if (editor.currentEditingImage) {
            editor.currentEditingImage.src = src
            editor.currentEditingImage.alt = alt
            editor.postState()
        } else {
            editor.insertHTML(`<img src="${escapeHTML(src)}" alt="${escapeHTML(alt)}" />`)
        }
    },

    insertVideoComment (mediaID) {
        editor.restoreRange()
        editor.insertHTML(videoPreviewHTML(mediaID))
    },

    setHTML (html) {
        content.innerHTML = html
        // replace <video> with preview <img>
        for (let video of document.querySelectorAll('video')) {
            video.outerHTML = videoPreviewHTML(video.dataset.media_comment_id)
        }
    },

    insertHTML (html) {
        document.execCommand('insertHTML', false, html)
        editor.postState()
    },

    getHTML () {
        // Images
        for (let img of document.querySelectorAll('img')) {
            img.classList.remove('editor-active')
            if (img.className === '') {
                img.removeAttribute('class')
            }
        }

        // Get the contents
        const clone = content.cloneNode(true)
        for (let styled of clone.querySelectorAll('[style]')) {
            // Replace rgb with hex because Canvas will remove rgb styles
            styled.setAttribute('style', rgbToHex(styled.style.cssText))
        }
        for (let remove of clone.querySelectorAll('.video-preview')) {
            remove.parentNode.removeChild(remove)
        }
        for (let comment of clone.querySelectorAll('p.last-video-comment')) {
            comment.classList.remove('last-video-comment')
        }
        let html = clone.innerHTML
        // backspaces can leave behind empty line breaks
        if (['<br>', '<div><br></div>'].includes(html)) {
            html = ''
        }
        return html
    },

    isEmpty () {
        return !content.querySelector('img') && !content.textContent.trim()
    },

    postState: throttle((e) => {
        const node = (e && e.target) || editor.getSelectedNode()

        let foreColor = document.queryCommandValue('foreColor') || (node && getComputedStyle(node).color)
        foreColor = rgbToHex(foreColor || '') || null

        let linkHref, linkText, imageSrc, imageAlt
        if (node) {
            let a = node.closest && node.closest('a')
            if (a) {
                editor.currentEditingLink = a
                linkHref = a.href
                linkText = a.textContent
            } else {
                linkText = getSelection().toString()
                editor.currentEditingLink = null
            }

            if (node instanceof HTMLImageElement) {
                editor.currentEditingImage = node
                imageSrc = node.src
                imageAlt = node.alt
            } else {
                editor.currentEditingImage = null
            }
        }

        webkit.messageHandlers.state.postMessage({
            undo: document.queryCommandEnabled('undo'),
            redo: document.queryCommandEnabled('redo'),
            bold: document.queryCommandState('bold'),
            italic: document.queryCommandState('italic'),
            orderedList: document.queryCommandState('insertOrderedList'),
            unorderedList: document.queryCommandState('insertUnorderedList'),
            isEmpty: editor.isEmpty(),
            foreColor, linkHref, linkText, imageSrc, imageAlt,
        })
    }),

    focus () {
        let range = document.createRange()
        range.selectNodeContents(content)
        range.collapse(false) // move to end
        let selection = getSelection()
        selection.removeAllRanges()
        selection.addRange(range)
        content.focus()
    },

    updateScroll: throttle(() => {
        const selection = getSelection()
        if (selection.rangeCount <= 0) return
        const span = document.createElement('span')
        const range = selection.getRangeAt(0).cloneRange()
        range.collapse(false)
        range.insertNode(span)
        const { bottom } = span.getBoundingClientRect()
        span.parentNode.removeChild(span)
        if (bottom > innerHeight) {
            scrollTo(0, scrollY + bottom - innerHeight + 16)
        }
    }),
}

const rgbToHex = (rgb) => {
    return rgb.replace(/\brgba?\s*\(\s*(\d+)\D+(\d+)\D+(\d+)\D*(\d+)?\D*\)/g, (s, r, g, b, a) => {
        return '#' + [a || 255, r, g, b]
            .map(n => (+n).toString(16).padStart(2, '0'))
            .join('')
            .replace(/^ff/i, '')
    })
}

const escapeHTML = (html) => {
    return html
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/'/g, '&#039;')
        .replace(/"/g, '&quot;')
}

const videoPreviewHTML = mediaID => {
    const src = `data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 111">
  <circle fill="none" stroke="white" stroke-width="3" cx="96" cy="55" r="25"/>
  <path fill="white" d="M90 45 l18 11-18 11z"/>
</svg>`.replace(/\r?\n\s*/g, '')
    let html = `<img class="video-preview" src='${src}' />`
    if (mediaID) {
        html += `<p class="last-video-comment"><a id="media_comment_${mediaID}" class="instructure_inline_media_comment video_comment" href="/media_objects/${mediaID}">this is a media comment</a></p>`
    }
    return html
}

function throttle (fn, ms = 200) {
  let timer, last
  return function () {
    const context = this, args = arguments
    const now = performance.now()
    if (now < last + ms) {
        clearTimeout(timer)
        timer = setTimeout(() => {
            last = now
            fn.apply(context, args)
        }, ms)
    } else {
        last = now
        fn.apply(context, args)
    }
  }
}

document.addEventListener('selectionchange', e => {
    editor.updateScroll()
    const empty = document.querySelector('#content>br:only-child')
    if (empty) { content.removeChild(empty) }
    editor.postState()
})

window.addEventListener('touchstart', e => {
    editor.isDragging = false
    if (e.target.tagName.toLowerCase() === 'img') {
        for (let img of document.querySelectorAll('img.editor-active')) {
            img.classList.remove('editor-active')
        }
        e.target.classList.add('editor-active')
    }
})
window.addEventListener('touchmove', e => {
    editor.isDragging = true
    editor.postState(e)
})
window.addEventListener('touchend', e => {
    editor.postState(e)
    if (!e.target.classList.contains('editor-active')) {
        for (let img of document.querySelectorAll('img.editor-active')) {
            img.classList.remove('editor-active')
        }
    }
    if (editor.currentEditingLink) {
        webkit.messageHandlers.link.postMessage('')
        e.preventDefault()
    }
    if (!editor.isDragging && e.target.nodeName.toLowerCase() === 'html') {
        editor.focus()
    }
})

content.addEventListener('blur', () => {
    if (editor.isEmpty()) { content.textContent = '' }
})

content.addEventListener('paste', e => {
    if (e.clipboardData.files.length) {
        e.preventDefault() // don't allow default pasting of a blob url for the file
        const uris = e.clipboardData.getData('text/uri-list').split('\r\n')
        for (let i = 0; i < e.clipboardData.files.length; ++i) {
            const file = e.clipboardData.files[i]
            const uri = uris[i]
            if (file.type.startsWith('image/') && uri) {
                document.execCommand('insertHTML', false, `<img src="${escapeHTML(uri)}" alt="${escapeHTML(file.name)}" />`)
            } else if (uri) {
                document.execCommand('insertHTML', false, `<a href="${escapeHTML(uri)}">${escapeHTML(uri)}</a>`)
            }
        }
    }
    editor.postState(e)
})

webkit.messageHandlers.ready.postMessage('')
