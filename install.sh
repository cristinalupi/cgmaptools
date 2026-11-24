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
  cd ..

  echo 'building samtools'
  cd samtools-*/
  make clean || true
  make CC="$CC" CFLAGS="-g -Wall -O2 -fcommon"
  cd ..
cd ..

cd src/
  echo 'building ATCGmapMerge'
  $CXX ATCGmapMerge.cpp -o ../bin/ATCGmapMerge -lz -L ../include/zlib-1.2.8

  echo 'building CGmapSelectByRegion'
  $CXX CGmapSelectByRegion.cpp -o ../bin/CGmapSelectByRegion

  echo 'building CGmapMethInBed'
  $CXX CGmapMethInBed.cpp -o ../bin/CGmapMethInBed

  echo 'building CGmapMethInFragReg'
  $CXX CGmapMethInFragReg.cpp -o ../bin/CGmapMethInFragReg

  echo 'building CGmapFromBAM'
  $CC -o ../bin/CGmapFromBAM CGmapFromBAM.c -lz -L ../include/zlib-1.2.8 -lbam -L ../include/samtools-0.1.18

  echo 'building CGmapToCGbz'
  $CC -o ../bin/CGmapToCGbz CGmapToCGbz.c -L ../include/zlib-1.2.8 -lbam -L ../include/samtools-0.1.18 -lz

  echo 'building CGbzToCGmap'
  $CC -o ../bin/CGbzToCGmap CGbzToCGmap.c -L ../include/zlib-1.2.8 -lbam -L ../include/samtools-0.1.18 -lz

  echo 'building ATCGmapToATCGbz'
  $CC -o ../bin/ATCGmapToATCGbz ATCGmapToATCGbz.c -L ../include/zlib-1.2.8 -lbam -L ../include/samtools-0.1.18 -lz

  echo 'building ATCGbzToATCGmap'
  $CC -o ../bin/ATCGbzToATCGmap ATCGbzToATCGmap.c -L ../include/zlib-1.2.8 -lbam -L ../include/samtools-0.1.18 -lz

  echo 'building CGbzFetchRegion'
  $CC -o ../bin/CGbzFetchRegion CGbzFetchRegion.c -L ../include/zlib-1.2.8 -lbam -L ../include/samtools-0.1.18 -lz

  echo 'building ATCGbzFetchRegion'
  $CC -o ../bin/ATCGbzFetchRegion ATCGbzFetchRegion.c -L ../include/zlib-1.2.8 -lbam -L ../include/samtools-0.1.18 -lz
cd ..

cd bin
  for pr in ../src/*.py ../src/*.pl ../src/*.R; do
    pn=$(basename "$pr" | cut -d"." -f1)
    echo "building $pn"
    ln -sf "$pr" "$pn"
    chmod +x "$pn"
  done
cd ..
