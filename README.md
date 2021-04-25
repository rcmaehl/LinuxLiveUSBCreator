[![Build Status](https://img.shields.io/github/workflow/status/rcmaehl/LinuxLiveUSBCreator/ncc)](https://github.com/rcmaehl/LinuxLiveUSBCreator/actions?query=workflow%3Alili)
[![Download](https://img.shields.io/github/v/release/rcmaehl/LinuxLiveUSBCreator)](https://github.com/rcmaehl/LinuxLiveUSBCreator/releases/latest/)
[![Ko-fi](https://img.shields.io/badge/Support%20me%20on-Ko--fi-FF5E5B.svg?logo=ko-fi)](https://ko-fi.com/rcmaehl)
[![PayPal](https://img.shields.io/badge/Donate%20on-PayPal-00457C.svg?logo=paypal)](https://paypal.me/rhsky)
[![Join the Discord chat](https://img.shields.io/badge/Discord-chat-7289da.svg?&logo=discord)](https://discord.gg/uBnBcBx)


# LinuxLiveUSBCreator
A fork of Thibaut Lauzièr's Linux Live USB Creator

This project aims to bring bug fixes and improvements to Linux Live USB Creator. The following are changes I've made or likely to make. Feedback is appreciated within the discord server linked above.

- [ ] Use executiable resources to allow LiLi to be a single executible instead of an executible and extra files.
    - [ ] Convert GUI Image creation calls to detect if compiled and use internal resources from #AutoIt3Wrapper_Res_Icon_Add
    - [ ] FileInstall or FileWrite needed .cfg files
- [ ] Improve error messages (e.g. Drive free space insuffient)
- [ ] Improve distro compatibility
    - [ ] Use common download paths to allow any common distro to be downloaded
    - [ ] Use common locations of CRC/SHA values to validate downloads instead of hard coded values
