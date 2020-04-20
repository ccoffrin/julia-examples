#!/usr/bin/env julia

# script with a simple command line interface

# the first line allows the script to be run like an executable from the
# terminal

function main(args::Vector{String})
    println("args given:")
    for arg in args
        println("  ", arg)
    end
end

# this isinteractive() check makes sure that main is not run when loading
# this script into the REPL
if !isinteractive()
    # ARGS is a julia defined constant for command line arguments
    main(ARGS)
end

# test with terminal commands like
#
#   ./cli.jl
#   ./cli.jl a 1.2 b
#

# test with REPL commands like
#
#   include("cli.jl")
#   main(String[])
#   main(["a", "1.2", "b"])
#
