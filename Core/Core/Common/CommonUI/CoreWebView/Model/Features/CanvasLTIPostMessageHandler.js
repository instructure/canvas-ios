/**
 * Canvas LTI PostMessage Handler for Mobile Apps
 *
 * This standalone JavaScript file handles LTI postMessage events in mobile webviews
 * where the full Canvas UI bundle is not loaded. It can be injected by mobile apps
 * to enable LTI tool functionality.
 *
 * This is a simplified, dependency-free version of the handlers found in canvas codebase:
 * - ui/shared/lti/jquery/messages.ts (main message handler)
 * - ui/shared/lti/jquery/subjects/lti.frameResize.ts (frameResize implementation)
 * - ui/shared/lti/jquery/subjects/lti.fetchWindowSize.ts (fetchWindowSize implementation)
 * - ui/shared/lti/jquery/response_messages.ts (response handling)
 *
 * Currently supports:
 * - lti.frameResize: Resizes iframe containing LTI tool
 * - lti.fetchWindowSize: Returns window dimensions and scroll position
 *
 * Copyright (C) 2024 - present Instructure, Inc.
 */

(function() {
  'use strict';

  // Prevent duplicate initialization
  if (window.__CANVAS_MOBILE_LTI_HANDLER_INITIALIZED__) {
    console.log('[Canvas Mobile LTI] Handler already initialized');
    return;
  }
  window.__CANVAS_MOBILE_LTI_HANDLER_INITIALIZED__ = true;

  console.log('[Canvas Mobile LTI] Initializing mobile LTI postMessage handler');

   /**
   * Find the iframe element that corresponds to the given window
   *
   * @param {Window} sourceWindow - The contentWindow of the iframe we're looking for
   * @param {Document} [startDocument=document] - The document to search in
   * @returns {HTMLIFrameElement|null} The iframe element or null if not found
   */
  function findDomForWindow(sourceWindow, startDocument) {
    startDocument = startDocument || document;
    var iframes = startDocument.getElementsByTagName('iframe');

    for (var i = 0; i < iframes.length; i++) {
      if (iframes[i].contentWindow === sourceWindow) {
        return iframes[i];
      }
    }

    return null;
  }

  /**
   * Sometimes the iframe which is the window we're looking for is nested within an RCE iframe.
   * Those are same-origin, so we can look through those RCE iframes' documents
   * too for the window we're looking for.
   *
   * @param {Window} sourceWindow - The contentWindow of the iframe we're looking for
   * @returns {HTMLIFrameElement|null} The iframe element or null if not found
   */
  function findDomForWindowInRCEIframe(sourceWindow) {
    var iframes = document.querySelectorAll('.tox-tinymce iframe');
    for (var i = 0; i < iframes.length; i++) {
      var doc = iframes[i].contentDocument;
      if (doc) {
        var domElement = findDomForWindow(sourceWindow, doc);
        if (domElement) {
          return domElement;
        }
      }
    }
    return null;
  }

  // ============================================================================
  // Response Message Functions (from ui/shared/lti/jquery/response_messages.ts)
  // ============================================================================

  /**
   * Build response message handlers
   *
   * @param {Object} config
   * @param {Window} config.targetWindow - The window to send responses to
   * @param {string} config.origin - The origin to send to
   * @param {string} config.subject - The message subject
   * @param {string} [config.message_id] - Optional message ID
   * @returns {Object} Response message helpers
   */
  function buildResponseMessages(config) {
    var targetWindow = config.targetWindow;
    var origin = config.origin;
    var subject = config.subject;
    var message_id = config.message_id;

    function sendResponse(contents) {
      contents = contents || {};
      var message = {
        subject: subject + '.response'
      };

      if (message_id) {
        message.message_id = message_id;
      }

      // Merge contents into message
      for (var key in contents) {
        if (contents.hasOwnProperty(key)) {
          message[key] = contents[key];
        }
      }

      if (targetWindow) {
        try {
          targetWindow.postMessage(message, origin);
          console.log('[Canvas Mobile LTI] Sent response:', message);
        } catch (e) {
          console.error('[Canvas Mobile LTI] Error sending postMessage:', e);
        }
      } else {
        console.error('[Canvas Mobile LTI] Cannot send response: target window does not exist');
      }
    }

    function sendSuccess() {
      sendResponse({});
    }

    function sendError(code, errorMessage) {
      var error = {code: code};
      if (errorMessage) {
        error.message = errorMessage;
      }
      sendResponse({error: error});
    }

    return {
      sendResponse: sendResponse,
      sendSuccess: sendSuccess,
      sendError: sendError
    };
  }

  // =================================================================================
  // Message Handlers (from canvas ui/shared/lti/jquery/subjects/lti.frameResize.ts)
  // =================================================================================

  /**
   * Handle lti.frameResize messages
   *
   * @param {Object} message - The parsed message object
   * @param {MessageEvent} event - The original message event
   * @param {Object} responseMessages - Response message helpers
   * @returns {boolean} True if response was already sent
   */
  function handleFrameResize(message, event, _responseMessages) {
    console.log('[Canvas Mobile LTI] Handling lti.frameResize:', message);

    var height = message.height;
    if (Number(height) <= 0) {
      height = 1;
    }

    // Find the iframe that sent the message (matching lti.frameResize.ts:39)
    // Try to find in main document first, then check if nested in RCE iframe
    var iframe = findDomForWindow(event.source) || findDomForWindowInRCEIframe(event.source);

    if (!iframe) {
      console.warn('[Canvas Mobile LTI] frameResize: could not find iframe for source window');
      // In the desktop version, this continues without error, so we do the same
      // (lti.frameResize.ts:46 returns false without sending error)
      return false;
    }

    // Apply the height (matching lti.frameResize.ts:41-43)
    var heightStr = typeof height === 'number' ? height + 'px' : height;
    iframe.height = heightStr;
    iframe.style.height = heightStr;

    console.log('[Canvas Mobile LTI] frameResize: resized iframe to', heightStr);

    return false;
  }

  /**
   * Handle lti.fetchWindowSize messages
   *
   * @param {Object} message - The parsed message object
   * @param {MessageEvent} event - The original message event
   * @param {Object} responseMessages - Response message helpers
   * @returns {boolean} True if response was already sent
   */
  function handleFetchWindowSize(_message, _event, responseMessages) {
    console.log('[Canvas Mobile LTI] Handling lti.fetchWindowSize');

    // Get the tool content wrapper element (matching lti.fetchWindowSize.ts:26)
    var toolWrapper = document.querySelector('.tool_content_wrapper');
    var offset = null;

    // Calculate offset if wrapper exists (vanilla JS equivalent of jQuery's offset())
    if (toolWrapper) {
      var rect = toolWrapper.getBoundingClientRect();
      offset = {
        top: rect.top + window.scrollY,
        left: rect.left + window.scrollX
      };
    }

    // Get footer height (matching lti.fetchWindowSize.ts:27)
    var fixedBottom = document.getElementById('fixed_bottom');
    var footerHeight = fixedBottom ? fixedBottom.offsetHeight : 0;

    // Build response (matching lti.fetchWindowSize.ts:23-29)
    var response = {
      height: window.innerHeight,
      width: window.innerWidth,
      offset: offset,
      footer: footerHeight,
      scrollY: window.scrollY
    };

    console.log('[Canvas Mobile LTI] fetchWindowSize response:', response);

    // Send response (matching lti.fetchWindowSize.ts:30 - returns true)
    responseMessages.sendResponse(response);
    return true;
  }

  /**
   * Main LTI message handler
   *
   * @param {MessageEvent} event - The message event
   */
  function ltiMessageHandler(event) {
    if (event.data === '') {
      return;
    }

    var message;
    try {
      message = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
    } catch (err) {
      // unparseable message may not be meant for our handlers
      return;
    }

    if (typeof message !== 'object' || message === null) {
      return;
    }

    // Get the subject (check messageType for backwards compatibility) (messages.ts:174)
    var subject = message.subject || message.messageType;

    if (!subject) {
      return;
    }

    console.log('[Canvas Mobile LTI] Received message with subject:', subject);

    // Build response message helpers (messages.ts:176-182)
    var responseMessages = buildResponseMessages({
      targetWindow: event.source,
      origin: event.origin,
      subject: subject,
      message_id: message.message_id
    });

    // Handle the message based on subject
    var hasSentResponse = false;

    switch (subject) {
      case 'lti.frameResize':
        hasSentResponse = handleFrameResize(message, event, responseMessages);
        break;

      case 'lti.fetchWindowSize':
        hasSentResponse = handleFetchWindowSize(message, event, responseMessages);
        break;

      default:
        console.log('[Canvas Mobile LTI] Ignoring unsupported message subject:', subject);
        return;
    }

    // If handler didn't send a response, send success (messages.ts:215-217)
    if (!hasSentResponse) {
      responseMessages.sendSuccess();
    }
  }

  // Register the message listener
  window.addEventListener('message', ltiMessageHandler);
  console.log('[Canvas Mobile LTI] Mobile LTI handler initialized successfully');

  // Expose handler info for debugging
  window.__CANVAS_MOBILE_LTI_HANDLER__ = {
    version: '1.0.0',
    supportedSubjects: ['lti.frameResize', 'lti.fetchWindowSize']
  };
})();
