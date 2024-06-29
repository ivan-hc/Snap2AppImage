# Snap2AppImage
An experimental script to convert Snap packages to portable AppImages

It is a proof of concept, it requires more study and attention to make it truly an efficient project.

### Requirements
Install `squashfs-tools` from your system package manager.

### Usage
1. Download the script and made it executable
```
wget -q https://raw.githubusercontent.com/ivan-hc/Snap2AppImage/main/snap2appimage.sh
chmod a+x snap2appimage.sh
```
2. Replace "APP=SAMPLE" with "APP=appmane" (where "appname" is the name of the Snap package you want to convert to an AppImage)
3. run the script wherever you want
```
./snap2appimage.sh
```
### Efficiency
The chances of success at the first launch are zero, it still requires manual modifications to adapt the script to the conditions necessary to create an efficient AppImage.

For now it only worked with [Chromium](https://github.com/ivan-hc/Chromium-Web-Browser-appimage) and [Skype](https://github.com/ivan-hc/Skype-appimage).

In this video I create Skype, after a long manual modification of the script.

https://github.com/ivan-hc/Skype-appimage/assets/88724353/6e665bb4-7807-4923-bbe7-a200bd238fe1

### Related projects
- "[**AM**](https://github.com/ivan-hc/AM)", package manager for AppImages
- "[ArchImage](https://github.com/ivan-hc/ArchImage)", create AppImages from a portable Arch Linux container (efficiency 90%)
- "[AppImaGen](https://github.com/ivan-hc/AppImaGen)", create Appimage packages from .deb packages (efficiency 50%)
- All my AppImage packages https://github.com/ivan-hc#my-appimage-packages
