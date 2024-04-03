func InitializeResponse(id) {
  msg_map := Map("Serverinfo", Map("name", "ahk-lsp", "Version", "0.0.1"), "Capabilities", Map("TextDocumentSync", 1))
  msg := EncodeMessage(msg_map)
  return msg
}

