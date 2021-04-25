[![Build Status](https://img.shields.io/github/workflow/status/rcmaehl/LinuxLiveUSBCreator/lili)](https://github.com/rcmaehl/LinuxLiveUSBCreator/actions?query=workflow%3Alili)
[![Download](https://img.shields.io/github/v/release/rcmaehl/LinuxLiveUSBCreator)](https://github.com/rcmaehl/LinuxLiveUSBCreator/releases/latest/)
[![Ko-fi](https://img.shields.io/badge/Support%20me%20on-Ko--fi-FF5E5B.svg?logo=ko-fi)](https://ko-fi.com/rcmaehl)
[![PayPal](https://img.shields.io/badge/Donate%20on-PayPal-00457C.svg?logo=paypal)](https://paypal.me/rhsky)
[![Join the Discord chat](https://img.shields.io/badge/Discord-chat-7289da.svg?&logo=discord)](https://discord.gg/uBnBcBx)


# Linux Live USB Creator
A fork of Thibaut Lauzièr's Linux Live USB Creator, obtained from http://www.linuxliveusb.com/en/about/sources
![image](https://user-images.githubusercontent.com/716581/115993652-b5012180-a5a1-11eb-81f8-cd3452d6e996.png)


## Goals
This project aims to bring bug fixes and improvements to Linux Live USB Creator. The following are changes I've made or likely to make. Feedback is appreciated within the discord server linked above.

- [ ] Improve executiable resources to allow LiLi to be a single executible instead of an executible and extra files.
    - [x] Convert GUI Image creation calls to detect if compiled and use internal resources from #AutoIt3Wrapper_Res_Icon_Add
        - [x] GUICtrlCreateGraphic / GUICtrlSetGraphic
        - [x] GUICtrlCreateIcon
        - [x] GUICtrlCreatePic
        - [x] GUICtrlSetImage
        - [x] GUISetIcon
        - [x] TraySetIcon / TraySetPauseIcon
        - [x] _GDIPlus_ImageLoadFromFile
    - [x] Add Themeing ability back by detecting a /theme/ directory, or similar
    - [ ] FileInstall or FileWrite needed .cfg files
- [ ] Improve error messages (e.g. Drive free space insuffient)
    - [ ] Improve translations (e.g. spaces between sentences and punctuation)
- [ ] Improve distro compatibility
    - [ ] Add popular distros that may not have been listed
        - [ ] If possible, list popular distros from TorrentWatch/Other Service automatically
    - [ ] Add torrent file fetching for distro downloading
    - [ ] Include information such as syslinux versions in a definitions file
        - [ ] Allow defintions file to be updated/downloaded seperately
    - [ ] Use common download paths to allow any common distro to be downloaded
    - [ ] Use common locations of CRC/SHA values to validate downloads instead of hard coded values ([#1](https://github.com/rcmaehl/LinuxLiveUSBCreator/issues/1))
        - [ ] Validate SHA values using their GPG keys (if available)
            - [ ] Warn but allow continuation if offline
            - [ ] Warn but allow continuation if no GPG verification
            - [ ] Warn but DO NOT allow continuation if SHA and ISO do not match
            - [ ] Warn but DO NOT allow continuation if SHA and GPG key do not match
- [ ] Improve Windows 10 handling
    - [x] Update @OSVersion calls
    - [ ] Check for other issues/conflicts
- [ ] Update updater check GitHub for updates
- [ ] Update contact information within files to not bother the old developer
    - [x] Convert Emails to Discord Links
    - [ ] Have bug reports generate a github issue

## Compiling from Source

* git clone rcmaehl/LinuxLiveUSBCreator
* Intall the latest AutoIt Version (https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.exe)
* (Recommended) Install the complete SciTE Editor (https://www.autoitscript.com/cgi-bin/getfile.pl?../autoit3/scite/download/SciTE4AutoIt3.exe)
* Run SciTE as Administrator to be able to see logging
* Navigate to sources/lili/
* Open "LiLi USB Creator.au3" and press F7 to compile
