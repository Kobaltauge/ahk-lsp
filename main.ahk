#include rpc\rpc.ahk
#include lib\json.ahk
#include lsp\initialize.ahk

#NoTrayIcon
#SingleInstance ignore
Logfile := A_ScriptName "_log.txt"

; FileDelete Logfile
FileAppend "started`n", Logfile

Loop {
  stdin  := FileOpen("*", "r")
  msg := RTrim(stdin.Read())
  if msg {
    FileAppend "in: " msg "`n", Logfile
    HandleMessage(msg) 
  }
}

HandleMessage(msg) {
  newmsg := DecodeMessage(msg)
  if Type(newmsg) = "Map" {
    switch newmsg["method"]
    {
      case "initialize":
        ansmsg := InitializeResponse(newmsg["id"])
        FileAppend "out: " ansmsg "`n", Logfile
        ByteSize := StrPut(ansmsg, "UTF-8")
        FileAppend ansmsg, "*"
      default: FileAppend "default`n", Logfile
    }
  }
}
