#!/usr/bin/env bash


while getopts "ibcs" opt; do
  case $opt in
    i)
      echo "INIT_SYSTEM"
      INIT_SYSTEM="Y"
      ;;
    b)
      echo "MAKE_BUILD"
      MAKE_BUILD="Y"
      ;;
    c)
      echo "START_CLIENT_NODE"
      START_CLIENT_NODE="Y"
      ;;
    s)
      echo "START_STORAGE_MINER"
      START_STORAGE_MINER="Y"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      ;;
  esac
done

if [ ! -z "${INIT_SYSTEM}" ]; then
  sysOS=`uname -s`
  if [ $sysOS == "Darwin" ];then
    echo "I'm MacOS"
    brew install go bzr jq pkg-config rustup
  elif [ $sysOS == "Linux" ];then
    echo "I'm Linux"
    sudo apt update
    sudo apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl
    sudo apt upgrade
  else
    echo "The OS is not supported: $sysOS"
  fi
fi

if [ ! -z "${MAKE_BUILD}" ]; then
#  make clean && make all
#  sudo make install

  rm -r ~/.lotus
  rm -r ~/.lotusstorage
  rm -r ~/.genesis-sectors
  rm -r /var/tmp/filecoin-parents
#  rm -r /var/tmp/filecoin-proof-parameters

  make 2k

  if [ ! -d "/var/tmp/filecoin-proof-parameters" ]; then
    #./lotus fetch-params 2048
    scp -r  root@192.168.13.129:/root/filecoin-proof-parameters /var/tmp/
  fi

  ./lotus-seed pre-seal --sector-size 2KiB --num-sectors 2
  ./lotus-seed genesis new localnet.json
  ./lotus-seed genesis add-miner localnet.json ~/.genesis-sectors/pre-seal-t01000.json
fi

if [ ! -z "${START_CLIENT_NODE}" ]; then
  ./lotus daemon --lotus-make-genesis=dev.gen --genesis-template=localnet.json --bootstrap=false
fi

if [ ! -z "${START_STORAGE_MINER}" ]; then
  ./lotus wallet import ~/.genesis-sectors/pre-seal-t01000.key
  ./lotus-storage-miner init --genesis-miner --actor=t01000 --sector-size=2KiB --pre-sealed-sectors=~/.genesis-sectors --pre-sealed-metadata=~/.genesis-sectors/pre-seal-t01000.json --nosync
  ./lotus-storage-miner run --nosync
fi