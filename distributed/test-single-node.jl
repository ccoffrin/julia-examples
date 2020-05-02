#!/usr/bin/env julia

max_threads = 12

using Distributed
if Distributed.nprocs() <= 2
    threads = min(trunc(Int, Sys.CPU_THREADS*0.75), max_threads)
    println("threads: $(threads)/$(Sys.CPU_THREADS)")

    proc_ids = Distributed.addprocs(threads)
    println("process ids: $(proc_ids)")
end

processes = Distributed.nprocs()-1 # save one for the master process
println("processes ids: $(processes)")

@everywhere function test(pid)
    println("pid: $(pid) - $(gethostname()) - $(pwd())")
end

solution2_files = pmap(test, 1:processes)

