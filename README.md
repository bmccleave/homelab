# Home Lab

This repository captures the scripts I have created to configure my home lab.

Note: I have leverage  copilot to generate some of these scripts.

My home setup is behind a basic Orbi router and I have a Intel Xeon Nuc that I am using to create VMs to test various scenarios.   I tend to treat the VM's like cattle and tear them down frequently as I test.

| Script | Description |
|--- | ---- |
| avahi-daemon-setup.sh | I install avahi-daemon on my unbuntu instances to support local DNS resolution.  This script has the settings I need to get i working |


Helper command to convert windows line endings to linux

```bash
sed -i 's/\r$//' your-script.sh
```