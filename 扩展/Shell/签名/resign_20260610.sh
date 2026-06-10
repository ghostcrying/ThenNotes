#!/bin/bash


# 用法: ./resign.sh <input_ipa> <cert_identity> <provision_file> [-v VERSION] [-b BUILD] [-i BUNDLE_ID] [output_ipa]

if [ $# -lt 3 ]; then
    echo "用法: $0 input.ipa cert_identity provision_file [-v VERSION] [-b BUILD] [-i BUNDLE_ID] [output.ipa]"
    echo "示例: $0 Feather/output.ipa \"Apple Distribution: Zarvish Mansib (68W647242G)\" dis_rates.mobileprovision -v 1.0.0 -b 1 -i com.new.bundleid"
    exit 1
fi

# 参数初始化
INPUT_IPA=""
CERT_IDENTITY=""
PROVISION_FILE=""
VERSION=""
BUILD_NUMBER=""
BUNDLE_ID=""
OUTPUT_IPA=""

# 参数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -b|--build)
            BUILD_NUMBER="$2"
            shift 2
            ;;
        -i|--bundle-id)
            BUNDLE_ID="$2"
            shift 2
            ;;
        *)
            if [ -z "$INPUT_IPA" ]; then
                INPUT_IPA="$1"
            elif [ -z "$CERT_IDENTITY" ]; then
                CERT_IDENTITY="$1"
            elif [ -z "$PROVISION_FILE" ]; then
                PROVISION_FILE="$1"
            else
                OUTPUT_IPA="$1"
            fi
            shift
            ;;
    esac
done

OUTPUT_IPA=${OUTPUT_IPA:-resigned_$(basename "$INPUT_IPA")}

# 检查输入文件
if [ ! -f "$INPUT_IPA" ]; then
    echo "错误: 输入 IPA 文件 $INPUT_IPA 不存在"
    exit 1
fi
if [ ! -f "$PROVISION_FILE" ]; then
    echo "错误: 描述文件 $PROVISION_FILE 不存在"
    exit 1
fi

# 临时目录
WORK_DIR="./tmp_$(date +%s)_$RANDOM"
mkdir -p "$WORK_DIR"
echo "工作目录: $WORK_DIR"

# 解压 IPA
echo "解压 $INPUT_IPA..."
unzip -qo "$INPUT_IPA" -d "$WORK_DIR"

# 找到 .app bundle
APP_PATH=$(find "$WORK_DIR/Payload" -type d -name "*.app" -maxdepth 1)
if [ -z "$APP_PATH" ]; then
    echo "错误: 未找到 .app bundle"
    exit 1
fi
echo "找到 App Bundle: $APP_PATH"

# 清理旧签名
echo "清理旧签名..."
rm -rf "$APP_PATH/_CodeSignature"
rm -f "$APP_PATH/embedded.mobileprovision"

# 移除原有签名
echo "移除原有签名..."
codesign --remove-signature "$APP_PATH" 2>/dev/null || true

# 替换 Provisioning Profile
echo "替换描述文件..."
cp "$PROVISION_FILE" "$APP_PATH/embedded.mobileprovision"

# ==================== 修改 Info.plist ====================
INFO_PLIST="$APP_PATH/Info.plist"

if [ -n "$VERSION" ] || [ -n "$BUILD_NUMBER" ] || [ -n "$BUNDLE_ID" ]; then
    echo "正在修改 Info.plist..."
    
    if [ -n "$BUNDLE_ID" ]; then
        echo "设置 Bundle ID = $BUNDLE_ID"
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$INFO_PLIST" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID" "$INFO_PLIST"
    fi
    
    if [ -n "$VERSION" ]; then
        echo "设置 版本号 (CFBundleShortVersionString) = $VERSION"
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$INFO_PLIST" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $VERSION" "$INFO_PLIST"
    fi
    
    if [ -n "$BUILD_NUMBER" ]; then
        echo "设置 构建号 (CFBundleVersion) = $BUILD_NUMBER"
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$INFO_PLIST" 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $BUILD_NUMBER" "$INFO_PLIST"
    fi
fi

# 生成 entitlements.plist
ENTITLEMENTS_PLIST="$WORK_DIR/entitlements.plist"
echo "生成 entitlements.plist..."
/usr/libexec/PlistBuddy -x -c "Print :Entitlements" /dev/stdin <<< $(security cms -D -i "$APP_PATH/embedded.mobileprovision") > "$ENTITLEMENTS_PLIST"

if [ ! -s "$ENTITLEMENTS_PLIST" ]; then
    echo "警告: entitlements.plist 为空，使用默认空文件"
    cat > "$ENTITLEMENTS_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict></dict>
</plist>
EOF
fi

# 签名框架和插件
echo "签名框架和插件..."
find "$APP_PATH/Frameworks" -type f \( -name "*.dylib" -o -perm +111 \) -exec codesign -f -s "$CERT_IDENTITY" --entitlements "$ENTITLEMENTS_PLIST" {} \; 2>/dev/null || true

# 签名主 App
echo "签名主应用..."
codesign -f -s "$CERT_IDENTITY" --entitlements "$ENTITLEMENTS_PLIST" "$APP_PATH"

# 验证签名
echo "验证最终签名..."
codesign -dv "$APP_PATH" 2>&1 | head -n 10

# 重新打包
echo "重新打包 IPA..."
cd "$WORK_DIR"
mkdir -p "$(dirname "$OUTPUT_IPA")"
zip -qry "$OUTPUT_IPA" Payload SwiftSupport 2>/dev/null || zip -qry "$OUTPUT_IPA" Payload

cd ..
echo "重签名完成: $OUTPUT_IPA"

# 可选：清理临时目录（取消注释即可）
# rm -rf "$WORK_DIR"
