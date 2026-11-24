#!/usr/bin/env bash
set -e

# Use Conda compilers if active, otherwise fallback to system gcc/g++
CC="${CC:-gcc}"
CXX="${CXX:-g++}"

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
  make CC="$CC" CFLAGS="-g -Wall -O2 -fcommon -I$ZLIB_INC -I${CONDA_PREFIX}/include" LDFLAGS="-L$ZLIB_INC -L${CONDA_PREFIX}/lib"
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
  $CC -o ../bin/CGmapFromBAM CGmapFromBAM.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building CGmapToCGbz'
  $CC -o ../bin/CGmapToCGbz CGmapToCGbz.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building CGbzToCGmap'
  $CC -o ../bin/CGbzToCGmap CGbzToCGmap.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building ATCGmapToATCGbz'
  $CC -o ../bin/ATCGmapToATCGbz ATCGmapToATCGbz.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building ATCGbzToATCGmap'
  $CC -o ../bin/ATCGbzToATCGmap ATCGbzToATCGmap.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building CGbzFetchRegion'
  $CC -o ../bin/CGbzFetchRegion CGbzFetchRegion.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz

  echo 'building ATCGbzFetchRegion'
  $CC -o ../bin/ATCGbzFetchRegion ATCGbzFetchRegion.c -I"$ZLIB_INC" -I"$SAMTOOLS_INC" -L"$ZLIB_INC" -L"$SAMTOOLS_INC" -lbam -lz
cd ..

cd bin
  for pr in ../src/*.py ../src/*.pl ../src/*.R; do
    pn=$(basename "$pr" | cut -d"." -f1)
    echo "building $pn"
    ln -sf "$pr" "$pn"
    chmod +x "$pn"
  done
cd ..
