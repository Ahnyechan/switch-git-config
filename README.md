# Git Config Switcher

Easily switch between multiple Git accounts (personal/work/etc) with simple scripts.

## Supported Platforms

- **Linux/macOS**: Bash script (`.sh`)
- **Windows PowerShell**: PowerShell script (`.ps1`)
- **Windows CMD**: Batch file (`.bat`)

## Features

- ✅ **Centralized Configuration**: Manage all profiles in a single `config.json` file
- ✅ **Multiple Profiles**: Support for unlimited Git accounts (not just 2!)
- ✅ **Cross-Platform**: Works on Linux, macOS, and Windows
- ✅ **Secure**: Configuration file can be excluded from version control
- ✅ **Easy to Use**: Simple interactive menu interface

## Installation

### 1. Create Configuration File

Copy the example configuration and customize it with your Git accounts:

```bash
cp config.example.json config.json
```

Edit `config.json` with your account information:

```json
{
  "profiles": [
    {
      "name": "Son Heungmin",
      "email": "heungmin@gmail.com",
      "label": "Personal"
    },
    {
      "name": "Son Heungmin",
      "email": "son.heungmin@company.com",
      "label": "Work"
    },
    {
      "name": "Lee Kangin",
      "email": "kangin@freelance.com",
      "label": "Freelance"
    }
  ]
}
```

**Note**: The `config.json` file is already in `.gitignore` to protect your personal information.

### 2. Make Scripts Executable (Linux/macOS only)

```bash
chmod +x switch-git-config.sh
```

## Usage

### Linux/macOS (Bash)
```bash
./switch-git-config.sh
```

### Windows PowerShell
```powershell
.\switch-git-config.ps1
```

**Note**: If you encounter execution policy errors:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Windows CMD
```cmd
switch-git-config.bat
```

## Example Output

```
Current Git Configuration:
  Name: Son Heungmin
  Email: heungmin@gmail.com

Which configuration would you like to switch to?
1) Personal (Son Heungmin <heungmin@gmail.com>)
2) Work (Son Heungmin <son.heungmin@company.com>)
3) Freelance (Lee Kangin <kangin@freelance.com>)
4) Cancel

Select (1-4): 2

✓ Switched to Work account.

Current Git Configuration:
  Name: Son Heungmin
  Email: son.heungmin@company.com
```

## Configuration File Format

The `config.json` file uses a simple JSON structure:

```json
{
  "profiles": [
    {
      "name": "Your Display Name",
      "email": "your.email@example.com",
      "label": "Profile Label"
    }
  ]
}
```

- **name**: The name that will appear in Git commits
- **email**: The email address for Git commits
- **label**: A friendly label to identify this profile (e.g., "Personal", "Work")

You can add as many profiles as you need!

## Requirements

### All Platforms
- Git installed and accessible from command line

### Linux/macOS (Bash)
- Bash shell
- Optional: `jq` for better JSON parsing
  - macOS: `brew install jq`
  - Ubuntu/Debian: `apt-get install jq`
  - The script works without `jq`, but it's recommended

### Windows (PowerShell)
- PowerShell 3.0 or later (included in Windows 8+)

### Windows (CMD)
- PowerShell must be available (used for JSON parsing)

## Quick Access (Optional)

### Bash (Linux/macOS)

Add an alias to `~/.bashrc` or `~/.zshrc`:
```bash
alias gitswitch='~/path/to/switch-git-config.sh'
```

Then use in terminal:
```bash
gitswitch
```

### PowerShell

Add a function to your PowerShell profile (`$PROFILE` file):
```powershell
function gitswitch {
    & "C:\path\to\switch-git-config.ps1"
}
```

Then use in PowerShell:
```powershell
gitswitch
```

### CMD

Add the script directory to your system PATH for global access.

## Important Notes

- This script modifies **global** Git configuration
- To use a different account for a specific repository only:
  ```bash
  git config user.name "Name"
  git config user.email "email@example.com"
  ```
- The `config.json` file contains personal information and is excluded from Git via `.gitignore`
- Always keep a backup of your `config.json` file

## Project Structure

```
switch-git-config/
├── switch-git-config.sh       # Bash script for Linux/macOS
├── switch-git-config.ps1      # PowerShell script for Windows
├── switch-git-config.bat      # Batch script for Windows CMD
├── config.example.json        # Example configuration (committed to Git)
├── config.json               # Your actual configuration (ignored by Git)
├── .gitignore                # Git ignore rules
└── README.md                 # This file
```

## Troubleshooting

### "config.json not found"
Run: `cp config.example.json config.json` and edit the file with your settings

### PowerShell Execution Policy Error
Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### Bash: "jq: command not found" Warning
This is just a warning. The script will work but installing `jq` is recommended:
- macOS: `brew install jq`
- Linux: `sudo apt-get install jq` or `sudo yum install jq`

### Windows CMD: JSON Parsing Errors
Ensure PowerShell is available on your system. It's included by default in Windows 7+

## License

MIT License

## Contributing

Issues and improvement suggestions are always welcome!
