# Claude for CAD Management - Quick Start Guide

*Get started with AI-powered CAD automation from a fresh Windows installation*

## Prerequisites

- Windows 10/11 computer
- Administrative rights to install software
- Internet connection
- Basic familiarity with AutoCAD or Civil 3D

## Step 1: Essential Software Setup

### Install WSL (Windows Subsystem for Linux)

1. **Enable WSL**
   ```powershell
   # Open PowerShell as Administrator
   wsl --install
   ```

2. **Restart your computer** when prompted

3. **Set up Ubuntu**
   - After restart, Ubuntu will automatically open
   - Create a username and password
   - Update the system:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

### Install Additional Tools

1. **Install Git for Windows**
   - Download from: https://git-scm.com/download/win
   - Use default settings during installation
   - This provides Git Bash terminal

2. **Install VS Code**
   - Download from: https://code.visualstudio.com/
   - Install WSL extension
   - Install Claude extension from marketplace
   - Optional: Install AutoLISP extension

## Step 2: Set Up Claude Access

### Option A: Basic Setup (Recommended for beginners)

1. **Create Claude Account**
   - Visit https://claude.ai
   - Sign up with email
   - Start with free tier to test concepts

2. **Upgrade to Claude Pro** (after testing)
   - $20/month subscription
   - Higher usage limits
   - Priority access during peak times

### Option B: Advanced Setup (For development work)

1. **Install Claude Code CLI in WSL**
   ```bash
   # Open WSL terminal
   curl -L https://claude.ai/install.sh | bash
   ```

2. **Login to Claude Code**
   ```bash
   claude login
   # Follow prompts to authenticate
   ```

## Step 3: Test Your Setup

### Basic Test with Claude.ai

1. Open https://claude.ai in your browser
2. Try this sample prompt:
   ```
   I'm a CAD manager working with AutoCAD. Can you help me write an AutoLISP script
   that counts all the text objects in the current drawing and reports the count?
   ```

### Advanced Test with WSL + Claude Code

1. **Clone this repository**
   ```bash
   # In WSL terminal
   git clone https://github.com/daniellench/AU2025
   cd AU2025
   ```

2. **Test Claude Code setup**
   ```bash
   claude --version
   claude ask "What files are in this directory?"
   ```

3. **Open project in VS Code from WSL**
   ```bash
   code .
   ```

## Step 4: Your First Automation

### Simple AutoLISP Generation

Ask Claude to create this automation:

**Prompt:** "Create an AutoLISP routine that:
1. Prompts user to select text objects
2. Changes all selected text to a standard height of 0.125
3. Reports how many objects were modified"

**Expected Result:** Working AutoLISP code you can load into AutoCAD

### Test the Code

1. Copy the generated code to a .lsp file
2. Save it to your Windows file system (accessible from `/mnt/c/` in WSL)
3. Load it in AutoCAD with `(load "filename.lsp")`
4. Run the command Claude provided
5. Verify it works with your drawing

## Step 5: Working Between Windows and WSL

### File System Access

- **Windows files from WSL:** `/mnt/c/Users/YourName/`
- **WSL files from Windows:** `\\wsl$\Ubuntu\home\yourusername\`
- **Recommended:** Keep CAD files on Windows, development tools in WSL

### Development Workflow

1. **Edit code in VS Code** (connected to WSL)
2. **Save files to Windows** for AutoCAD access
3. **Run Claude Code from WSL** for AI assistance
4. **Test in AutoCAD** on Windows

## Step 6: Expand Your Usage

### Immediate Next Steps

1. **Create a prompt library** - Save successful prompts for reuse
2. **Document your standards** - Upload company CAD standards to Claude
3. **Start with repetitive tasks** - Identify manual processes to automate

### Common Use Cases to Try

- **Standards checking scripts** - Verify layer names, text heights, etc.
- **Batch processing** - Modify multiple drawings at once
- **Drawing cleanup** - Remove unused layers, blocks, styles
- **Report generation** - Extract data from drawings to Excel

## Troubleshooting

### Common Issues

**"WSL not installing"**
- Ensure Windows version is 10 build 19041+ or Windows 11
- Enable virtualization in BIOS if needed
- Run PowerShell as Administrator

**"Claude Code command not found"**
- Restart WSL terminal after installation
- Check PATH with `echo $PATH`
- Try manual installation steps

**"Can't access Windows files from WSL"**
- Files are at `/mnt/c/Users/YourName/`
- Check file permissions
- Use `explorer.exe .` to open Windows Explorer from WSL

**"AutoLISP code not working"**
- Check parentheses are balanced
- Verify command names are correct
- Test with simple drawings first

### Getting Help

1. **Community Resources**
   - GitHub Issues in this repository
   - AutoCAD forums with "AI" or "Claude" tags
   - CAD manager communities

2. **Professional Support**
   - Implementation consulting available
   - Custom training sessions
   - Direct support for enterprise deployments

## Next Steps

After completing this quickstart:

1. **Read the full documentation** in other files in this repository
2. **Join the community** - Links in main README
3. **Share your success** - Contribute examples back to the project
4. **Scale up** - Move from individual scripts to full workflow automation

## ROI Expectations

**Time Investment:** 3-5 hours for initial setup (including WSL)
**Expected Savings:** 5-10 hours per week after first month
**Break-even Point:** Usually within 2-3 weeks

*Remember: Start small, prove value, then expand usage*

---

**Need Help?** Open an issue in this repository or contact the maintainers directly.

**Ready for More?** Check out the other guides in this repository for advanced integrations and enterprise deployments.