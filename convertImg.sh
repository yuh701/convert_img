#!/bin/sh

IMG_WIDTH="800" # 画像の横幅を指定(px)
COMPRESS_RATE="70" # 画像の圧縮クオリティー、小さいほど、容量は小さくなるが画像が荒くなる。0~100で指定

INPUT_PATH=$1
TMP_OUTPUT_PATH="./tmp"
OUTPUT_PATH="./complete"

if [ $# != 1 ]; then
    echo "引数に画像があるディレクトリパスを指定してください。例"
    echo "/Users/hoge/Desktop/image"
    exit 1
fi

cd $INPUT_PATH
if [ ! $? = 0 ]; then
    echo "${INPUT_PATH}:ディレクトリに移動できませんでした。"
    exit 1
fi

if [ ! -e $TMP_OUTPUT_PATH ]; then
    mkdir $TMP_OUTPUT_PATH
fi
if [ ! -e $OUTPUT_PATH ]; then
    mkdir $OUTPUT_PATH
fi

find . -iname '*.HEIC' | xargs -IT basename T .HEIC | xargs -IT sips --setProperty format jpeg ./T.HEIC --out $TMP_OUTPUT_PATH/T.jpg;
if [ ! $? = 0 ]; then
    echo "HEICファイルを変換できませんでした"
    exit 1
fi

find . -iname '*.png' | xargs -IT basename T .png | xargs -IT sips --setProperty format jpeg ./T.png --out $TMP_OUTPUT_PATH/T.jpg;
if [ ! $? = 0 ]; then
    echo "pngファイルを変換できませんでした"
    exit 1
fi

cp *.jpg *.jpeg $TMP_OUTPUT_PATH
find $TMP_OUTPUT_PATH -iname '*.jpg' -o -iname '*.jpeg' | xargs -IT basename T | xargs -IT sips -Z $IMG_WIDTH $TMP_OUTPUT_PATH/T --out $TMP_OUTPUT_PATH/T;
if [ ! $? = 0 ]; then
    echo "ファイルを横:${IMG_WIDTH}pxにリサイズできませんでした"
    exit 1
fi

rm $OUTPUT_PATH/*
jpegoptim --strip-all -m $COMPRESS_RATE -d $OUTPUT_PATH $TMP_OUTPUT_PATH/*
if [ ! $? = 0 ]; then
    echo "画像圧縮できませんでした。"
    exit 1
fi

beforeSize=`du -k $TMP_OUTPUT_PATH | cut -f 1`
afterSize=`du -k $OUTPUT_PATH | cut -f 1`
echo width=$IMG_WIDTH, 圧縮率=$COMPRESS_RATE
echo 合計削減サイズ：$((100-afterSize*100/beforeSize))%
echo $beforeSize $TMP_OUTPUT_PATH
echo $afterSize $OUTPUT_PATH
rm -r $TMP_OUTPUT_PATH
