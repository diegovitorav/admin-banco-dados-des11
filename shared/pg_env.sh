# pg_env.sh
set -a  # ativa export automático

PG_VERSION="17.2"
PG_USER="postgres"
PG_HOME="/home/${PG_USER}"
PG_INSTALL_DIR="/usr/local/pgsql"
PGBIN="${PG_INSTALL_DIR}/bin"
PGDATA="/db/data"
PGLOG="${PG_HOME}/logfile"
PREFIX="/usr/local/pgsql"
DOWNLOAD_URL="https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz"
SRC_DIR="/tmp/postgresql-${PG_VERSION}"
TARBALL="/tmp/postgresql-${PG_VERSION}.tar.gz"
REGRESSION_LOG="/tmp/pg_regression.log"
CONFIGURE_LOG="/tmp/pg_configure.log"
MAKE_COMPILE_LOG="/tmp/pg_make.log"
MAKE_INSTALL_LOG="/tmp/pg_install.log"
PG_BUILD_DEPS="gcc gcc-c++ make bison flex perl systemd-devel"

set +a  # desativa export automático