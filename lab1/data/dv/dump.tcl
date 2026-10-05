database -open waves -shm -into waves.shm
probe -create tb/dut -database waves -all -depth all

simvision {
    waveform new -reuse -name dut
    waveform using dut
    browser select deep tb.dut
    waveform add -selected
}

run
