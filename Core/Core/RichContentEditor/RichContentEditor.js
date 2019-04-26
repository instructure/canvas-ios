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

    insertImagePlaceholder (url, placeholder) {
        editor.restoreRange()
        editor.insertHTML(`<img src="${escapeHTML(placeholder)}" alt="" data-uploading="${escapeHTML(url)}" />`)
    },

    insertVideoPlaceholder (url) {
        editor.restoreRange()
        editor.insertHTML(`<img src='${videoUploadURL}' alt="" data-uploading="${escapeHTML(url)}" data-media_comment_id />`)
    },

    updateUploadProgress (files) {
        for (let file of files) {
            let img = document.querySelector(`[data-uploading="${file.localFileURL}"]`)
            let progress = document.querySelector(`[data-progress="${file.localFileURL}"]`)
            if (!img) {
                if (progress) progress.remove()
            } else if (file.uploadError) {
                img.remove()
                if (progress) progress.remove()
            } else if (file.mediaEntryID) {
                img.src = videoPreviewURL
                img.dataset.media_comment_id = file.mediaEntryID
                delete img.dataset.uploading
                if (progress) progress.remove()
            } else if (file.url) {
                img.src = file.url
                delete img.dataset.uploading
                if (progress) progress.remove()
            } else {
                progress = progress || progressElement(file.localFileURL)
                const fill = progress.querySelector('.progress-fill')
                const circum = 2 * fill.r.baseVal.value * Math.PI
                fill.style.strokeDashoffset = 1000 - (((file.bytesSent / file.size) || 0) * circum)
            }
        }
        editor.updateOverlays()
    },

    updateOverlays () {
        for (let button of document.querySelectorAll('.remove-image')) {
            if (!button.removesImage.parentNode) {
                button.remove()
            }
        }
        for (let img of content.querySelectorAll('img')) {
            let bounds = img.getBoundingClientRect()
            if (img.dataset.uploading) {
                let progress = document.querySelector(`[data-progress="${img.dataset.uploading}"]`)
                if (!progress) continue
                progress.style.left = `${bounds.left + (bounds.width / 2) + scrollX}px`
                progress.style.top = `${bounds.top + (bounds.height / 2) + scrollY}px`
            } else {
                let button = img.removeButton || (img.removeButton = removeButton(img))
                if (!button.parentNode) { document.body.appendChild(button) } // fix undo breaking it
                button.style.left = `${bounds.right + (bounds.width < 40 ? 20 : 0) + scrollX}px`
                button.style.top = `${bounds.top + (bounds.height < 40 ? -20 : 0) + scrollY}px`
            }
        }
    },

    setHTML (html) {
        content.innerHTML = html
        for (let video of document.querySelectorAll('video')) {
            let mediaID = video.dataset.media_comment_id
            video.outerHTML = `<img src='${videoPreviewURL}' alt="" data-media_comment_id="${mediaID}" />`
        }
    },

    insertHTML (html) {
        document.execCommand('insertHTML', false, html)
        editor.postState()
    },

    getHTML () {
        // Get the contents
        const clone = content.cloneNode(true)
        for (let styled of clone.querySelectorAll('[style]')) {
            // Replace rgb with hex because Canvas will remove rgb styles
            styled.setAttribute('style', rgbToHex(styled.style.cssText))
        }
        for (let remove of clone.querySelectorAll('[data-uploading]')) {
            remove.remove() // There shouldn't be any, but just in case.
        }
        for (let img of clone.querySelectorAll('[data-media_comment_id]')) {
            let mediaID = img.dataset.media_comment_id
            img.outerHTML = `<a id="media_comment_${mediaID}" class="instructure_inline_media_comment video_comment" href="/media_objects/${mediaID}">this is a media comment</a>`
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
        span.remove()
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

const progressElement = url => {
    const progress = document.body.appendChild(document.createElement('div'))
    progress.setAttribute('aria-hidden', null)
    progress.className = 'progress'
    progress.dataset.progress = url
    progress.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="44" height="44">
  <circle class="progress-track" stroke-width="4" cx="22" cy="22" r="20"/>
  <circle class="progress-fill" stroke-width="4" cx="22" cy="22" r="20"/>
</svg>`
    return progress
}

const removeButton = img => {
    const button = document.body.appendChild(document.createElement('button'))
    button.setAttribute('aria-hidden', null)
    button.className = 'remove-image'
    button.removesImage = img
    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1920" width="18" height="18">
  <path d="M771.55 960.11L319 1412.66l188.56 188.56 452.55-452.55 452.55 452.55 188.56-188.56-452.55-452.55 452.55-452.55L1412.66 319 960.1 771.55 507.56 319 319 507.56z"/>
</svg>`
    button.onclick = () => { img.remove() }
    return button
}

const videoUploadURL = `data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg"></svg>`
const videoPreviewURL = `data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 111">
  <circle fill="none" stroke="white" stroke-width="3" cx="96" cy="55" r="25"/>
  <path fill="white" d="M90 45 l18 11-18 11z"/>
</svg>`.replace(/\r?\n\s*/g, '')

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

new MutationObserver(() => {
    editor.updateOverlays()
}).observe(content, { attributes: true, characterData: true, childList: true, subtree: true })

window.addEventListener('touchstart', e => {
    editor.isDragging = false
})
window.addEventListener('touchmove', e => {
    editor.isDragging = true
    editor.postState(e)
})
window.addEventListener('touchend', e => {
    editor.postState(e)
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
