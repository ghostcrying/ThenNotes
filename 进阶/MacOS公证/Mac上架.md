```
codesign --deep -f --entitlements "" -s "3rd Party Mac Developer Application: xxxxxx Co.,Ltd (VQ3IY989UY87)" -v xxxx.app 

codesign -dvvv --entitlements  - xxxx.app

productbuild --sign "3rd Party Mac Developer Installer: xxxxxxxx Co.,Ltd (VQ3IY989UY87)" --component xxxx.app /Applications/ xxxx.pkg


productbuild --sign "3rd Party Mac Developer Installer: xxxxxxxx Co.,Ltd (VQ3IY989UY87)" --product xxxx.app/Contents/Info.plist xxxx.pkg
```

