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
install_resource 'UIXML/back24x24.png'
install_resource 'UIXML/chevron.png'
install_resource 'UIXML/confirm24x24.png'
install_resource 'UIXML/edit32x32.png'
install_resource 'UIXML/write32x32.png'
install_resource 'WEPopover/popoverArrowDown.png'
install_resource 'WEPopover/popoverArrowDown@2x.png'
install_resource 'WEPopover/popoverArrowDownSimple.png'
install_resource 'WEPopover/popoverArrowLeft.png'
install_resource 'WEPopover/popoverArrowLeft@2x.png'
install_resource 'WEPopover/popoverArrowLeftSimple.png'
install_resource 'WEPopover/popoverArrowRight.png'
install_resource 'WEPopover/popoverArrowRight@2x.png'
install_resource 'WEPopover/popoverArrowRightSimple.png'
install_resource 'WEPopover/popoverArrowUp.png'
install_resource 'WEPopover/popoverArrowUp@2x.png'
install_resource 'WEPopover/popoverArrowUpSimple.png'
install_resource 'WEPopover/popoverBg.png'
install_resource 'WEPopover/popoverBg@2x.png'
install_resource 'WEPopover/popoverBgSimple.png'
