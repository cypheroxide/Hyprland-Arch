P# Graphics Toggle Script Error Analysis

## Error Description
When running `toggle-graphics.sh`, the script fails with the error:
```
Invalid BootOrder order entry value0001,0006,0000
                                   ^
efibootmgr: entry 0000 does not exist
```

## Root Cause
The script is attempting to set a boot order that includes boot entry `0000`, which does not exist in the EFI boot manager configuration.

**Problem Location:** Lines 65 and 71 in `toggle-graphics.sh`

```bash
# Line 65 - switch_to_integrated()
sudo efibootmgr -o "${INTEGRATED_BOOT_ID},${HYBRID_BOOT_ID},0000,2001,2002,2003" >/dev/null

# Line 71 - switch_to_hybrid()
sudo efibootmgr -o "${HYBRID_BOOT_ID},${INTEGRATED_BOOT_ID},0000,2001,2002,2003" >/dev/null
```

## Current Boot Configuration
The system has the following boot entries:
- `0001` - Arch Linux Zen (Integrated) - AMD iGPU only
- `0003` - EFI PXE 0 for IPv4
- `0004` - EFI PXE 0 for IPv6
- `0006` - Arch Linux Zen (Hybrid) - AMD + NVIDIA dGPU
- `0007` - EFI PXE 0 for IPv6 (duplicate)
- `2001` - EFI USB Device
- `2002` - EFI DVD/CDROM
- `2003` - EFI Network

**Boot entry `0000` does not exist.**

## Steps to Fix

### Fix 1: Remove the Non-Existent Entry
Remove `0000` from the boot order command in both functions.

**Line 65** should be changed from:
```bash
sudo efibootmgr -o "${INTEGRATED_BOOT_ID},${HYBRID_BOOT_ID},0000,2001,2002,2003" >/dev/null
```
to:
```bash
sudo efibootmgr -o "${INTEGRATED_BOOT_ID},${HYBRID_BOOT_ID},2001,2002,2003" >/dev/null
```

**Line 71** should be changed from:
```bash
sudo efibootmgr -o "${HYBRID_BOOT_ID},${INTEGRATED_BOOT_ID},0000,2001,2002,2003" >/dev/null
```
to:
```bash
sudo efibootmgr -o "${HYBRID_BOOT_ID},${INTEGRATED_BOOT_ID},2001,2002,2003" >/dev/null
```

### Verification
After making these changes, test the script:
```bash
# Test status command
./toggle-graphics.sh status

# Test toggle command
./toggle-graphics.sh toggle

# Or test specific modes
./toggle-graphics.sh integrated
./toggle-graphics.sh hybrid
```

## Additional Notes
- The script correctly identifies boot entries 0001 and 0006 for the two UKI kernels
- The SecureBoot, TPM2 encryption, and UKI signing are not affected by this error
- The error only affects the boot order setting, not the boot entries themselves
- The script's error handling (line 109) correctly catches this error and prevents execution

## Summary
The "Invalid Value" error occurs because the script references boot entry `0000` which doesn't exist in your EFI configuration. Simply remove `0000,` from the boot order commands in lines 65 and 71 to resolve the issue.
