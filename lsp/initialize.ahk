InitializeResponse(id) {
  ;map_response := Map("jsonrpc", "2.0", "ID", id)
  ;map_serverinfo := Map("Name", "ahk-lsp", "Version", "0.0.1")
  ;map_capabilities := Map("TextDocumentSync", 1)
  ;msg_map := 
  ;msg_map := Map("jsonrpc", "2.0", "id", id, "result", Map("serverInfo", Map("name", "ahk-lsp", "version", "0.0.1"), "capabilities", Map("textDocumentSync", 1)))
  msg_map := Map("id", id, "result", Map("serverInfo", Map("name", "ahk-lsp", "version", "0.0.1"), "capabilities", Map("textDocumentSync", 1)))
  msg := EncodeMessage(msg_map)
  return msg
}

