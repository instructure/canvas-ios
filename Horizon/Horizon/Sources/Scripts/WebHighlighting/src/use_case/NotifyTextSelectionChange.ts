import getCurrentTextSelection from "./GetCurrentTextSelection";

export default function registerNotifyOnTextSelectionChange() {
  document.addEventListener("selectionchange", async () => {
    const messageHandlers = window.webkit?.messageHandlers;
    if (!messageHandlers) return;
      
    const currentTextSelection = await getCurrentTextSelection();
    window.webkit.messageHandlers.notebookTextSelectionChange.postMessage(
      JSON.stringify(currentTextSelection)
    );
  });
}
