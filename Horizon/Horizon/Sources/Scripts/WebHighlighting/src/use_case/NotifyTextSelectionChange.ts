import getCurrentTextSelection from "./GetCurrentTextSelection";

export default function registerNotifyOnTextSelectionChange() {
  document.addEventListener("selectionchange", async () => {
    const currentTextSelection = await getCurrentTextSelection();
    window.webkit.messageHandlers.notebookTextSelectionChange.postMessage(
      JSON.stringify(currentTextSelection)
    );
  });
}
