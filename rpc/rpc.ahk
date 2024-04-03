
EncodeMessage(msg) {
  value := Jxon_Dump(msg)
  encmsg := "Content-Length: " . Strlen(value) . "`r`n`r`n" . value
  ; FileAppend encmsg, "log.txt"
  return encmsg
}

DecodeMessage(msg) {
  ; msg := 'Content-Length: 50\r\n\r\n{"jsonrpc": "2.0", "id": 1, "method": "initialize"}'
  ; FileAppend msg, Logfile
  msg_array := StrSplit(msg, "`r`n`r`n")
  if msg_array.Length = 2 {
    json := msg_array[2]
    jdata := Jxon_Load(&json)
  } else {
    jdata := Map()
  }
  return jdata
}

