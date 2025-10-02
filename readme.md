# Windows Quick Setup / Utility Script Collection

Central repository of quick Windows personalization / setup scripts plus utility helpers. Some items are curated third‑party snippets/tools placed here for convenience (original authors credited where possible).

---

## 1. Purpose & Scope
Fast bootstrap of a fresh (or newly re-imaged / corporate) Windows workstation:
- Apply personal ergonomics (key remaps, Alt+Tab behavior, hide distracting UI).
- Enable execution of further scripts (execution policy bootstrap).
- Set common developer environment preferences (Git identity / proxy).
- Host additional small Windows helper tools in one grab-and-go repo.

Scripts are intentionally:
- Standalone (no external module dependency unless stated).
- Idempotent or safe to re-run.
- Clear about elevation requirements (HKLM edits need Admin).

---

## 2. Quick Start

(1) If PowerShell policy = Restricted and you cannot run .ps1:
Run (double-click) `allow_ps1_bootstrap.cmd` (temporary bypass + set CurrentUser policy RemoteSigned).

(2) Fine tune execution policy thereafter with `allow_ps1.ps1` (supports Process / CurrentUser / LocalMachine scopes).

(3) Apply desired tweaks (see Script Catalog).

(4) (Optional) Add or pull more helper tools into this repo as needed.

---

## 3. Script Catalog

| Script | Elevation | Category | Key Action |
|--------|-----------|----------|------------|
| `allow_ps1_bootstrap.cmd` | No | Bootstrap | Temporarily bypass + set CurrentUser policy RemoteSigned. |
| `allow_ps1.ps1` | Only if LocalMachine scope chosen | Policy Mgmt | Flexible execution policy manager. |
| `git_setup.ps1` | No | Dev Env | Configure global Git proxy / user.name / user.email (edit file to customize). |
| `hide_spotlight_info_icon.ps1` | No | UI Clean | Keep Spotlight wallpaper; hide desktop "Learn about this picture" icon. |
| `set_alt_tab_windows_only.ps1` | No | UX | Restrict Alt+Tab to windows (hide Edge/app tabs). |
| `swap_caps_ctrl_enable.ps1` | Yes (HKLM) | Ergonomics | Swap Caps Lock and Left Ctrl (Scancode Map). Logoff/reboot required. |
| `swap_caps_ctrl_disable.ps1` | Yes (HKLM) | Ergonomics | Revert Caps/Ctrl swap. |

---

## 4. Usage Examples

PowerShell (non-elevated unless noted):
``powershell
# Run a standard script
powershell -ExecutionPolicy Bypass -File .\set_alt_tab_windows_only.ps1

# Manage execution policy for current process only
powershell -ExecutionPolicy Bypass -File .\allow_ps1.ps1 -Scope Process -Policy Bypass

# Elevation (will prompt) to modify HKLM:
powershell -ExecutionPolicy Bypass -File .\swap_caps_ctrl_enable.ps1
``

Revert execution policy (optional):
``powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Undefined -Force
``

---

## 5. Elevation Matrix

- Requires Admin: Any script writing HKLM (key remap: swap_caps_ctrl_enable / disable).
- Does NOT need Admin: Policy bootstrap (CurrentUser), Git setup (global in user profile), UI tweaks under HKCU.

---

## 6. FAQ

Q: Policy blocks running scripts (Restricted)?
A: Run `allow_ps1_bootstrap.cmd` first, then refine with `allow_ps1.ps1`.

Q: Remap not working immediately?
A: HKLM Scancode Map needs logoff or reboot.

Q: Alt+Tab tweak not applied?
A: Usually instant. If not, sign out/in or restart Explorer.

Q: Where are third-party sourced tools?
A: (When added) They will live beside first-party scripts with attribution comments in-file.

---

## 7. Adding New Items

Place the script/tool at repo root (or create a logical subfolder if category growth demands). Then append a row to the Script Catalog table and (optionally) add:
- Brief purpose
- Elevation requirement
- Category tag
Keep descriptions concise, in English (add Chinese summary only if clarity needed).

---

## 8. Attribution & Licensing

Not all content is original. For any third-party script:
- Retain original header/comments.
- Add a short provenance comment: Source URL / author.
If removal is requested by an original author, comply promptly.

Unless a file states otherwise, assume personal-use convenience. Add explicit LICENSE file later if standardization becomes necessary.

---

## 9. Roadmap (Light)

- Add right-click context menu management utilities.
- Add common dev environment bootstrap (VS Code settings sync snippet, winget bundle).
- Optional: Introduce /tools folder for binary utilities with checksums.

---

## 10. Disclaimer

Use at your own risk. Review scripts before executing, especially those requiring elevation (HKLM modifications). Always understand a registry change before applying it.

---

Contributions (curated additions or refinements) are welcome—keep the minimal, practical focus.