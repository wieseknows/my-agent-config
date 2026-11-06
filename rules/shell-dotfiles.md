# Bash / Shell / Dotfiles standards

- **Portability:** Support both Git Bash (MINGW64 on Windows) and Linux. Use Bash features available on both platforms; avoid platform-specific assumptions and GNU-only extensions. Do not assume `readlink -f`, GNU `sed`, or GNU `date` are available.
- **Idempotency:** All installation scripts must be safe to run repeatedly. Running `install.sh` multiple times must not create duplicate entries, overwrite user changes, or break existing configurations.
- **Safe file operations:** Before replacing an existing file or symlink, preserve user data. Back up existing files when necessary. Never silently overwrite user-managed configuration.
- **Quoting:** Always quote variable expansions and paths (`"$VAR"`, `"$HOME"`). Handle spaces and special characters in filenames correctly. Use arrays for command arguments instead of building command strings.
- **Error handling:** Handle command failures explicitly. Use `set -euo pipefail` only when its behavior is appropriate; do not rely on it as a substitute for proper error handling. Never suppress errors without a documented reason.
- **Path handling:** Use `$HOME` instead of hardcoded home directory paths. Resolve paths relative to the script location, not the current working directory. Handle paths containing spaces.
- **Platform detection:** Detect OS and shell environment explicitly when platform-specific behavior is required. Keep platform-specific logic isolated and provide a portable fallback where possible.
- **Dependencies:** Do not assume optional utilities are installed. Check for required commands before using them and provide a clear error message if a dependency is missing.
- **Validation:** Every new or modified Bash script must pass `shellcheck` and `bash -n`. Fix warnings rather than suppressing them; any necessary suppression must include a justification.
- **Secrets and local configuration:** Secrets, tokens, credentials, private key paths, and machine-specific settings belong only in `.bashrc.local` and `.gitconfig.local`. Never read, inspect, print, copy, modify, or commit their contents. Preserve existing references to these files.
- **Git safety:** Never force-overwrite user changes, run destructive Git commands, or modify the user's Git configuration without explicit authorization. Local configuration files must remain untracked.
- **Aliases and functions:** Every new or modified user-facing alias or shell function must have a corresponding entry in `README.md`, including a short description and usage example where appropriate.
- **Documentation:** Keep README examples synchronized with actual scripts, aliases, functions, and installation behavior. Document required dependencies and platform-specific limitations.
- **Installation testing:** Before testing changes to `install.sh`, run it with an isolated temporary `HOME`. Never use the real user's home directory for installation tests. Verify created files, symlinks, permissions, and repeated execution.
- **Temporary files:** Use safe temporary-file creation (`mktemp`), clean up temporary resources with traps where appropriate, and never leave test artifacts in the repository or user's home directory.
- **Destructive operations:** Require explicit confirmation before deleting files, replacing user data, changing permissions recursively, or modifying system-level configuration.
- **Scope control:** Modify only files necessary for the requested task. Do not reformat unrelated scripts or restructure the dotfiles repository without a clear reason.
- **Testing:** Test both successful execution and failure scenarios. Verify behavior with paths containing spaces and missing optional dependencies. Do not claim a script is tested unless the relevant checks were actually executed.