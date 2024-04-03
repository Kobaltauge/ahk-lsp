script :=
(
FileAppend Auto
Sleep, 1000
FileAppend Hot
Sleep, 1000
FileAppend key
)

DynaRunReadStdOut(script, "ShowStdOutFromChild")

ShowStdOutFromChild(out := "") {
   static EM_SETSEL := 0xB1, EM_REPLACESEL := 0xC2
        , hGui, _ := ShowStdOutFromChild()
   SendMessage, EM_SETSEL, -2, -1, Edit1, ahk_id %hGui%
   SendMessage, EM_REPLACESEL, false, &out, Edit1, ahk_id %hGui%
}

ConsoleClose() {
   ExitApp
}

DynaRunReadStdOut(script, callBack := "", encoding := "CP0", args*)
{
   static HANDLE_FLAG_INHERIT := 0x00000001, flags := HANDLE_FLAG_INHERIT
        , STARTF_USESTDHANDLES := 0x100, CREATE_NO_WINDOW := 0x08000000
        , params := [ "UInt", PIPE_ACCESS_OUTBOUND     := 0x2, "UInt", 0
                    , "UInt", PIPE_UNLIMITED_INSTANCES := 255, "UInt", 0
                    , "UInt", 0, "Ptr", 0, "Ptr", 0, "Ptr" ]
        , BOM := Chr(0xFEFF)
   
   DllCall("CreatePipe", "PtrP", hPipeRead, "PtrP", hPipeWrite, "Ptr", 0, "UInt", 0)
   DllCall("SetHandleInformation", "Ptr", hPipeWrite, "UInt", flags, "UInt", HANDLE_FLAG_INHERIT)
   
   VarSetCapacity(STARTUPINFO , siSize :=    A_PtrSize*4 + 4*8 + A_PtrSize*5, 0)
   NumPut(siSize              , STARTUPINFO)
   NumPut(STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize*4 + 4*7)
   NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*3)
   NumPut(hPipeWrite          , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*4)
   
   VarSetCapacity(PROCESS_INFORMATION, A_PtrSize*2 + 4*2, 0)
   
   pipeName := "AHK_" . A_TickCount
   for k, v in ["pipeGA", "pipe"]
      %v% := DllCall("CreateNamedPipe", "Str", "\\.\pipe\" . pipeName, params*)
   
   sCmd := A_AhkPath . " ""\\.\pipe\" . pipeName . """"
   for k, v in args
      sCmd .= " """ . v . """"
      
   if !DllCall("CreateProcess", "UInt", 0, "Str", sCmd, "UInt", 0, "UInt", 0, "Int", true, "UInt", CREATE_NO_WINDOW
                              , "UInt", 0, "UInt", 0, "Ptr", &STARTUPINFO, "Ptr", &PROCESS_INFORMATION)
   {
      DllCall("CloseHandle", "Ptr", hPipeRead)
      DllCall("CloseHandle", "Ptr", hPipeWrite)
      for k, v in ["pipeGA", "pipe"]
         DllCall("CloseHandle", "Ptr", %v%)
      throw "CreateProcess failed"
   }
   DllCall("CloseHandle", "Ptr", hPipeWrite)
   for k, v in ["pipeGA", "pipe"]
      DllCall("ConnectNamedPipe", "Ptr", %v%, "Ptr", 0)
   tempScript := BOM . script
   tempScriptSize := ( StrLen(tempScript) + 1 ) << !!A_IsUnicode
   DllCall("WriteFile", "Ptr", pipe, "Str", tempScript, "UInt", tempScriptSize, "UIntP", 0, "Ptr", 0)
   
   for k, v in ["pipeGA", "pipe"]
      DllCall("CloseHandle", "Ptr", %v%)
   
   VarSetCapacity(sTemp, 4096), nSize := 0
   while DllCall("ReadFile", "Ptr", hPipeRead, "Ptr", &sTemp, "UInt", 4096, "UIntP", nSize, "UInt", 0) {
      sOutput .= stdOut := StrGet(&sTemp, nSize, encoding)
      ( callBack && %callBack%(stdOut) )
   }
   DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION))
   DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize))
   DllCall("CloseHandle", "Ptr", hPipeRead)

   Return sOutput
}