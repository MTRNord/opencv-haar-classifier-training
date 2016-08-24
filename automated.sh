#!/bin/bash/

echo -e "
 __  _                _       ___                                       _    _               \n
/ _\| |_  __ _  _ __ | |_    / _ \ _ __  ___  _ __    __ _  _ __  __ _ | |_ (_)  ___   _ __  \n
\ \ | __|/ _` || '__|| __|  / /_)/| '__|/ _ \| '_ \  / _` || '__|/ _` || __|| | / _ \ | '_ \ \n
_\ \| |_| (_| || |   | |_  / ___/ | |  |  __/| |_) || (_| || |  | (_| || |_ | || (_) || | | |\n
\__/ \__|\__,_||_|    \__| \/     |_|   \___|| .__/  \__,_||_|   \__,_| \__||_| \___/ |_| |_|\n
                                             |_|                                             \n
"
echo -e "Scaling Images to same size"
cd positive_images/; for i in *.jpg ; do convert "$i" -resize 80x40 "${i%.*}.jpg" ; done; cd ..
#cd negative_images/; for i in *.jpg ; do convert "$i" -resize 80x40 "${i%.*}.jpg" ; done; cd ..

echo -e "Gernerating positives.txt and negatives.txt"
find ./positive_images -iname "*.jpg" > positives.txt
find ./negative_images -iname "*.jpg" > negatives.txt

echo -e "Create Samples"
perl bin/createsamples.pl positives.txt negatives.txt samples 1500\
  "opencv_createsamples -bgcolor 0 -bgthresh 0 -maxxangle 1.1\
  -maxyangle 1.1 maxzangle 0.5 -maxidev 40 -w 80 -h 40"

echo -e "Merge Samples"
python ./tools/mergevec.py -v samples/ -o samples.vec

echo -e "Learning"
opencv_traincascade -data classifier -vec samples.vec -bg negatives.txt\
  -numStages 20 -minHitRate 0.999 -maxFalseAlarmRate 0.5 -numPos 1000\
  -numNeg 600 -w 80 -h 40 -mode ALL -precalcValBufSize 1024\
  -precalcIdxBufSize 1024
