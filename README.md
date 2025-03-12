# Ubuntu System Diagnostics

A comprehensive diagnostic tool for Ubuntu systems that performs thorough health checks and generates detailed reports.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Output](#output)
- [Available Checks](#available-checks)
- [Contributing](#contributing)
- [License](#license)

## Overview

This utility performs a comprehensive diagnostic scan of Ubuntu 22.04 LTS systems, capturing critical information about system health, performance, and configuration. The diagnostic report is saved to a log file for easy review and troubleshooting.

## Features

- Comprehensive system health analysis
- Safety-first approach with read-only operations
- Detailed logs with timestamps
- Compressed backup of reports
- Analysis of kernel, disk, memory, network, and security components

## Requirements

- Ubuntu 22.04 LTS (may work on other versions but is optimized for 22.04)
- Root/sudo access
- Basic packages: smartmontools (for disk SMART checks)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Gautham-Ramkumar03/ubuntu-system-diagnostics.git
   cd ubuntu-system-diagnostics
   ```

2. Make the script executable:
   ```bash
   chmod +x ubuntu-system-check.sh
   ```

3. Install dependencies:
   ```bash
   sudo apt update
   sudo apt install smartmontools
   ```

## Usage

Run the script with sudo privileges:

```bash
sudo ./ubuntu-system-check.sh
```

## Output

The script saves detailed diagnostic reports to:
- `/var/log/system_diagnostics/diagnostic_TIMESTAMP.txt`
- A compressed version is also created at `/var/log/system_diagnostics/diagnostic_TIMESTAMP.txt.gz`

## Available Checks

The diagnostic tool examines:

| Category | Checks Performed |
|----------|-----------------|
| System | Kernel information, Ubuntu version |
| Kernel | Recent messages, errors, warnings |
| File System | Disk space, file system integrity |
| Storage | SMART disk health status |
| Memory | RAM usage, swap status, virtual memory |
| Boot | GRUB configuration and status |
| Packages | Package errors, APT database |
| Services | Failed services, system status |
| Hardware | PCI devices, USB devices, block devices |
| Sensors | Temperature readings (if available) |
| Network | Interface configuration, open ports |
| Security | AppArmor status, firewall configuration |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
