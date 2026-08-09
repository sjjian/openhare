Pod::Spec.new do |s|
  s.name             = 'go_impl'
  s.version          = '0.0.1'
  s.summary          = 'Shared Go FFI layer (Oracle, SQL Server, …).'
  s.description      = <<-DESC
Go-based shared native library for Dart FFI: Oracle (go-ora), SQL Server (go-mssqldb), and future drivers in one archive.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  # CocoaPods 需要可编译目标才能产出 framework；真实二进制由下方脚本覆盖。
  s.source_files     = 'Classes/dummy.c'
  s.dependency 'FlutterMacOS'
  s.platform         = :osx, '10.11'

  # Go 编译在 ../src/CMakeLists.txt；此处只调 cmake 并写入 framework。
  s.script_phase = {
    :name => 'Build and embed go_impl (cmake c-shared)',
    :script => <<-SCRIPT,
set -e
BUILD_DIR="${DERIVED_FILE_DIR}/go_impl_cmake"
cmake -S "$PODS_TARGET_SRCROOT/../src" -B "$BUILD_DIR" -DGO_IMPL_OSX_ARCHS="$ARCHS"
cmake --build "$BUILD_DIR"

FW="${BUILT_PRODUCTS_DIR}/go_impl.framework"
FW_BIN="${FW}/Versions/A/go_impl"
INSTALL_ID="@rpath/go_impl.framework/Versions/A/go_impl"
if [ ! -e "$FW_BIN" ]; then
  FW_BIN="${FW}/go_impl"
  INSTALL_ID="@rpath/go_impl.framework/go_impl"
fi
cp "${BUILD_DIR}/libgo_impl.dylib" "$FW_BIN"
chmod u+w "$FW_BIN"
install_name_tool -id "$INSTALL_ID" "$FW_BIN"
SCRIPT
    :execution_position => :after_compile,
    :always_out_of_date => '1',
  }

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }
  s.swift_version = '5.0'
end
