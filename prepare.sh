# prepare.sh --

set -xe

(cd .. && sh autogen.sh)
sh ../configure.sh

### end of file
