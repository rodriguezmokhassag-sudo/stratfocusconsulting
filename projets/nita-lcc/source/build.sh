set -e
for dims in "3840 2160 16x9" "2160 3840 9x16"; do
  set -- $dims
  pids=""
  for i in 0 1 2 3; do python3 render.py $1 $2 $((i*150)) $(((i+1)*150)) part_$3_$i.mp4 > log_$3_$i.txt 2>&1 & pids="$pids $!"; done
  wait $pids
  printf "file 'part_$3_%d.mp4'\n" 0 1 2 3 > list_$3.txt
  ffmpeg -v error -y -f concat -safe 0 -i list_$3.txt -i music.wav -map 0:v -map 1:a -c:v copy -c:a aac -b:a 256k -af loudnorm=I=-14:TP=-1.5:LRA=9 -shortest -movflags +faststart NITA_LCC_$3_4K.mp4
done
echo DONE
