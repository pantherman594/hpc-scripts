export TERM=xterm
export PATH="$PATH:/usr/mpi/gcc/openmpi-4.1.0rc5/bin"

if ! hash mpicc 2>/dev/null; then
  echo "Could not find mpicc. Is it in your path?"
  exit 1
fi

git clone https://github.com/IO500/io500.git
cd io500

./prepare.sh
make

if ! test -f io500; then
  echo "io500 failed to build."
  exit 1
fi

cat > config-quick.ini<< EOF
[global]
timestamp-datadir = FALSE
timestamp-resultdir = FALSE
verbosity = 1

[debug]
# For a valid result, the stonewall timer must be set to the value according to the rules, it can be smaller for testing
stonewall-time = 10

[ior-easy]
transferSize = 2m
blockSize = 2048m

[mdtest-easy]
n = 1024

[ior-hard]
segmentCount = 1024

[mdtest-hard]
n = 1024

[find]
pfind-queue-length = 128
EOF

salloc -n4 --ntasks-per-node 2 mpirun -np 4 ./io500 config-quick.ini

zip -r result_$(date +%s).zip results

echo "==== RESULTS ===="
cat results/result_summary.txt
