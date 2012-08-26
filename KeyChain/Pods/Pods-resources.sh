#!/bin/sh

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *)
      echo "cp -R ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      cp -R "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowDown.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowDown@2x.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowDownSimple.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowLeft.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowLeft@2x.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowLeftSimple.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowRight.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowRight@2x.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowRightSimple.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowUp.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowUp@2x.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverArrowUpSimple.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverBg.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverBg@2x.png'
install_resource '../../../../../../../Users/softphone/WORKSPACES/GITHUB/iphone-commons-utilities/KeyChain/Pods/WEPopover/popoverBgSimple.png'
