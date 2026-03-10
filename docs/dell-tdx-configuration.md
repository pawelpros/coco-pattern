# Enable Intel TDX on Dell PowerEdge via iDRAC

This guide provides step-by-step instructions for enabling Intel Trust Domain Extensions (TDX) on Dell PowerEdge servers using the iDRAC console.

## Prerequisites

- Dell 16th Generation PowerEdge server:
  - PowerEdge R660, R660xs
  - PowerEdge R760, R760xs, R760xd2, R760XA
  - PowerEdge R860, R960
  - PowerEdge XE8640, XE9640, XE9680
  - PowerEdge C6620, MX760c
  - PowerEdge XR5610, XR7620, XR8610t, XR8620t
  - PowerEdge T360, T560
- 5th Gen Intel Xeon Scalable processor with TDX support
- **8 or 16 DIMMs per socket** (required memory configuration)
- Latest BIOS firmware installed

## Step-by-Step Instructions (Order Matters)

> **IMPORTANT:** Settings must be configured in this exact order. Some options (like "Multiple Keys") will be greyed out until prerequisite settings are applied. You may need to **save and reboot between steps** for dependent options to become available.

### 1. Access BIOS Setup via iDRAC

1. Log into the iDRAC web console
2. Navigate to **Configuration → BIOS Settings**
3. Alternatively, launch **Virtual Console** and press **F2** during POST to enter System Setup

### 2. Configure Memory Settings (FIRST)

Navigate to: **System BIOS → Memory Settings**

| Setting                | Value       |
| ---------------------- | ----------- |
| **Node Interleaving**  | Disabled    |

**Save and reboot** before proceeding.

### 3. Configure Processor Prerequisites (SECOND)

Navigate to: **System BIOS → Processor Settings**

| Setting                          | Value    |
| -------------------------------- | -------- |
| **Logical Processor (x2APIC)**   | Enabled  |
| **CPU Physical Address Limit**   | Disabled |

**Save and reboot** before proceeding.

### 4. Enable Memory Encryption - Multiple Keys (THIRD)

Navigate to: **System BIOS → System Security**

| Setting               | Value          |
| --------------------- | -------------- |
| **Memory Encryption** | Multiple Keys  |

> If "Multiple Keys" is still greyed out, verify steps 2 and 3 were applied and the system was rebooted.

**Save and reboot** before proceeding.

### 5. Configure TDX Settings (FOURTH)

Navigate to: **System BIOS → System Security** (or **Processor Settings** depending on BIOS version)

| Setting                                           | Value   |
| ------------------------------------------------- | ------- |
| **Global Memory Integrity**                       | Disabled |
| **Intel TDX (Trust Domain Extension)**            | Enabled |
| **TME-MT/TDX Key Split**                          | 1       |
| **TDX Secure Arbitration Mode Loader (SEAM)**     | Enabled |

### 6. Configure SGX Settings (FIFTH)

Navigate to: **System BIOS → Processor Settings → Software Guard Extensions (SGX)**

| Setting              | Value                     |
| -------------------- | ------------------------- |
| **Intel SGX**        | Enabled                   |
| **SGX Factory Reset** | Off                      |
| **SGX PRMRR Size**   | As needed (e.g., 64GB)    |

### 7. Final Save and Reboot

1. Press **Escape** to exit menus
2. Select **Save Changes and Exit**
3. System will reboot with TDX enabled

## Configuration Summary (Order of Operations)

```text
1. Disable Node Interleaving          → Save & Reboot
2. Enable x2APIC Mode                 → Save & Reboot
3. Disable CPU Physical Address Limit → Save & Reboot
4. Set Memory Encryption = Multiple Keys → Save & Reboot
5. Disable Global Memory Integrity
6. Enable Intel TDX
7. Set TME-MT/TDX Key Split = 1
8. Enable SEAM Loader
9. Enable Intel SGX                   → Final Save & Reboot
```

## Verification

After the OS boots, verify TDX is enabled:

```bash
# Check kernel messages for TDX
dmesg | grep -i tdx
# Should show: "virt/tdx: BIOS enabled: private KeyID range: [X, Y)"

# Check for TDX module
ls /sys/firmware/tdx_seam/
```

## Troubleshooting

### "Multiple Keys" Option is Greyed Out

This is typically caused by:

1. **Node Interleaving is Enabled** - Must be disabled first
2. **x2APIC Mode is Disabled** - Must be enabled first
3. **CPU Physical Address Limit is Enabled** - Must be disabled first
4. **System not rebooted** - Some changes require reboot before dependent options appear
5. **Insufficient DIMMs** - Requires 8 or 16 DIMMs per socket

### Settings Not Available

If TDX-related settings are not visible:

1. Ensure BIOS firmware is updated to the latest version
2. Verify your processor supports TDX (5th Gen Xeon Scalable required)
3. Contact Dell support for BIOS with TDX support

### TDX Not Detected by OS

If the OS doesn't detect TDX after configuration:

1. Verify all settings are correctly applied in the order specified
2. Ensure the OS/kernel supports TDX (Linux 6.2+ recommended)
3. Check that Memory Encryption is set to "Multiple Keys" (not "Single Key")

## References

- [Dell: Enable Intel TDX on Dell 16G Intel Servers](https://www.dell.com/support/kbdoc/en-us/000226452/enableinteltdxondell16g)
- [Intel TDX Enabling Guide - Hardware Setup](https://cc-enabling.trustedservices.intel.com/intel-tdx-enabling-guide/04/hardware_setup/)
- [Dell Info Hub: Enable Intel TDX in BIOS](https://infohub.delltechnologies.com/en-us/l/securing-ai-workloads-on-dell-poweredge-with-intel-xeon-processors-using-intel-trust-domain-extensions/appendix-b-enable-intel-r-tdx-in-bios/)
- [Linux Kernel TDX Documentation](https://docs.kernel.org/arch/x86/tdx.html)
