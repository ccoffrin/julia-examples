#!/usr/bin/env julia

using ClusterManagers
using Distributed

# this appears to be the point of diminishing returns
max_node_processes = 12

"turns a slurm node list into a list of node names"
function parse_node_names(slurm_node_list::String)
    node_names = String[]
    slurm_node_list_parts = split(slurm_node_list, "[")
    node_name_prefix = slurm_node_list_parts[1]

    #if only one node was found then this length will be 1
    if length(slurm_node_list_parts) == 1
        push!(node_names, node_name_prefix)
    else
        # this assumes all nodes have a common prefix and the nodelist has the form [1-2,4,5-10,12]
        node_ids = split(split(slurm_node_list_parts[2], "]")[1], ",")
        for node_id in node_ids
            node_id_parts = split(node_id, "-")
            start = parse(Int, node_id_parts[1])
            stop = parse(Int, length(node_id_parts) == 1 ? node_id_parts[1] : node_id_parts[2])
            digits = length(node_id_parts[1])
            for i in start:stop
                node_name = "$(node_name_prefix)$(lpad(string(i), digits, "0"))"
                push!(node_names, node_name)
            end
        end
    end
    return node_names
end

function add_local_procs()
    proc_ids = Int[]
    if Distributed.nprocs() <= 2
        node_processes = min(trunc(Int, Sys.CPU_THREADS*0.75), max_node_processes)
        println("local processes: $(node_processes) of $(Sys.CPU_THREADS)")

        proc_ids = Distributed.addprocs(node_processes)
    end
    return proc_ids
end

function add_remote_procs()
    proc_ids = addprocs(SlurmManager(4), partition="scaling")

    return proc_ids
end


function add_procs()
    proc_ids = add_local_procs()
    remote_proc_ids = add_remote_procs()

    for pid in remote_proc_ids
        push!(proc_ids, pid)
    end

    println("process ids: $(proc_ids)")
    return proc_ids
end


println("spin up workers")
add_procs()


println("define hello function on all workers")
@everywhere function hello(task::Int)
    println("I am working on task $(task)")
    return "task $(task) complete"
end

println("execute in parallel")
value = pmap(hello, [i for i in 1:Distributed.nprocs()])
sleep(1) # wait for stdout to catchup
println("result: $(value)")
println("execute complete")
