#!/usr/bin/sh

# all lengths 500 samples



l1=1000.0
l2=4500.0
ns=100
nt=15
n0=30
for ((i = 1 ; i <= $nt  ; i++));
do
   r=$((i+n0))
   echo 'julia ../test/square.jl --l1' $l1 '--l2 '$l2' --runid '$r' --nsamples '$ns
   julia ../test/square.jl --l1 $l1 --l2 $l2 --runid $r --nsamples $ns &
done
