#!/usr/bin/env bash
set -e

# Use Conda compilers if active, otherwise fallback to system gcc/g++
CC="${CC:-gcc}"
CXX="${CXX:-g++}"
CFLAGS_C="-std=gnu89 -Wno-incompatible-pointer-types"

rm -rf bin/
mkdir -p bin/

cd include
  echo 'building zlib'
  cd zlib-*/
  make clean || true
  CC="$CC" ./configure --prefix="$(pwd)"
  make CC="$CC"
  ZLIB_INC="$(pwd)"
  cd ..

  echo 'building samtools'
  cd samtools-*/
  make clean || true
  make libbam.a CC="$CC" \
    CFLAGS="-g -Wall -O2 -fcommon -I$ZLIB_INC -I${CONDA_PREFIX}/include" \
    DFLAGS="-D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -D_USE_KNETFILE -D_CURSES_LIB=0" \
    LIBCURSES=""
  SAMTOOLS_INC="$(pwd)"
  cd ..
cd ..

cd src/
  echo 'building ATCGmapMerge'
  $CXX ATCGmapMerge.cpp -o ../bin/ATCGmapMerge -I"$ZLIB_INC" -L"$ZLIB_INC" -lz

  echo 'building CGmapSelectByRegion'
  $CXX CGmapSelectByRegion.cpp -o ../bin/CGmapSelectByRegion

  echo 'building CGmapMethInBed'
  $CXX CGmapMethInBed.cpp -o ../bin/CGmapMethInBed

  echo 'building CGmapMethInFragReg'
  $CXX CGmapMethInFragReg.cpp -o ../bin/CGmapMethInFragReg

  echo 'building CGmapFromBAM'
  $CC $CFLAGS_C -o ../bin/CGmapFromBAM CGmapFromBAM.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building CGmapToCGbz'
  $CC $CFLAGS_C -o ../bin/CGmapToCGbz CGmapToCGbz.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building CGbzToCGmap'
  $CC $CFLAGS_C -o ../bin/CGbzToCGmap CGbzToCGmap.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building ATCGmapToATCGbz'
  $CC $CFLAGS_C -o ../bin/ATCGmapToATCGbz ATCGmapToATCGbz.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building ATCGbzToATCGmap'
  $CC $CFLAGS_C -o ../bin/ATCGbzToATCGmap ATCGbzToATCGmap.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building CGbzFetchRegion'
  $CC $CFLAGS_C -o ../bin/CGbzFetchRegion CGbzFetchRegion.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building ATCGbzFetchRegion'
  $CC $CFLAGS_C -o ../bin/ATCGbzFetchRegion ATCGbzFetchRegion.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz
cd ..

cd bin
  for pr in ../src/*.py ../src/*.pl ../src/*.R; do
    pn=$(basename "$pr" | cut -d"." -f1)
    echo "building $pn"
    ln -sf "$pr" "$pn"
    chmod +x "$pn"
  done
cd ..

echo ""
echo "CGmapTools installation finished."
echo ""
