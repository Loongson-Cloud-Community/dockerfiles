#!/bin/bash

# 需要安装的依赖包列表
DEPENDENCIES=(
    "cmake"
    "gcc"
    "gcc-c++"
    "make"
    "rpcgen"
    "diffutils"
    "patch"
    "libfido2-devel"
    "rpcsvc-proto-devel"
    "libicu-devel"
    "libedit-devel"
    "libevent-devel"
    "curl-devel"
    "libzstd-devel"
    "lz4-devel"
    "protobuf-devel"
    "openssl-devel"
    "libtirpc-devel"
    "ncurses-devel"
    "numactl-devel"
    "systemd-devel"
    "libaio-devel"
)

# 安装依赖包
echo "正在安装依赖包..."
dnf install -y "${DEPENDENCIES[@]}"

# 检查安装是否成功
if [ $? -ne 0 ]; then
    echo "依赖包安装失败，请检查错误信息。"
    exit 1
fi

# 设置一些变量
MYSQL_SRC_DIR="/tmp/mysql-8.0.40"  # 替换为实际的 MySQL 源代码目录
BUILD_DIR="${MYSQL_SRC_DIR}/build"     # 构建目录
INSTALL_DIR="/usr/local/mysql"         # 安装目录

# 确保构建目录存在
mkdir -p "$BUILD_DIR"
cd "$MYSQL_SRC_DIR"

# 设置 CMake 配置选项
cmake \
  -DCMAKE_C_FLAGS="-fPIC" \
  -DCMAKE_CXX_FLAGS="-fPIC" \
  -DBUILD_CONFIG="mysql_release" \
  -DCMAKE_INSTALL_PREFIX="/usr/local/mysql" \
  -DINSTALL_LIBDIR="lib" \
  -DINSTALL_PLUGINDIR="lib/plugin" \
  -DINSTALL_SUPPORTFILESDIR="share/support-files" \
  -DINSTALL_LAYOUT=RPM \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DTMPDIR="/var/tmp" \
  -DWITH_BOOST=boost \
  -DWITH_EMBEDDED_SERVER=OFF \
  -DFORCE_INSOURCE_BUILD=1 \
  -DWITH_UNIT_TESTS=OFF \
  -DWITH_ROUTER=OFF \
  -DWITH_SYSTEM_LIBS=ON \
  -DMYSQL_UNIX_ADDR="/usr/local/mysql/mysql.sock" \
  -DDAEMON_NAME="mysqld" \
  -DNICE_PROJECT_NAME="MySQL" \
  -DWITH_SYSTEMD=1 \
  -DSYSTEMD_SERVICE_NAME="mysqld" \
  -DSYSTEMD_PID_DIR="/run/mysqld" \
  -DWITH_PROTOBUF=bundled

# 编译 MySQL
make -j$(nproc)

# 安装 MySQL
make install

# 安装必要的目录
install -d -m 0751 "${INSTALL_DIR}/var/lib/mysql"
install -d -m 0755 "${INSTALL_DIR}/run/mysqld"
install -d -m 0750 "${INSTALL_DIR}/var/lib/mysql-files"
install -d -m 0750 "${INSTALL_DIR}/var/lib/mysql-keyring"

# 安装日志轮转和配置文件
install -D -m 0644 packaging/rpm-common/mysql.logrotate /etc/logrotate.d/mysql
install -D -m 0644 packaging/rpm-common/my.cnf /etc/my.cnf
install -d /etc/my.cnf.d

# 清理多余的文件
rm -rf "${INSTALL_DIR}/share/mysql-test" "${INSTALL_DIR}/lib64/*.a"

# 安装 sysusers 文件
#install -p -D -m 0644 "${MYSQL_SRC_DIR}/mysql.sysusers" /etc/sysusers.d/mysql.sysusers

# 更新共享库缓存
/sbin/ldconfig

echo "MySQL 已成功构建并安装！"

