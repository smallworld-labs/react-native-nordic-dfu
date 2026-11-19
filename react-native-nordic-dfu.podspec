require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-nordic-dfu"
  s.version      = package['version']
  s.summary      = package['description']

  s.authors      = { "Pilloxa" => "recruitment@pilloxa.com" }
  s.homepage     = "https://github.com/smallworldus/react-native-nordic-dfu"
  s.license      = "Apache License 2.0"
  s.platform     = :ios, "13.4"

  s.source       = { :git => "https://github.com/smallworldus/react-native-nordic-dfu.git" }
  s.source_files = "ios/**/*.{h,m,mm}"
  # RNNordicDfu.h is the only header apps import (for the static hooks). The
  # session header pulls in the NordicDFU Swift module and stays internal.
  s.public_header_files  = "ios/RNNordicDfu.h"
  s.private_header_files = "ios/RNNordicDfuSession.h"

  # NordicDFU replaces the deprecated iOSDFULibrary pod (same library, renamed).
  # It is a Swift pod and is imported as a clang module (`@import NordicDFU;`),
  # which works both as a static library and with `use_frameworks!`.
  s.dependency 'NordicDFU', '~> 4.17'

  # React-Core, the codegen'd spec (RNNordicDfuSpec) and the TurboModule deps.
  install_modules_dependencies(s)
end
