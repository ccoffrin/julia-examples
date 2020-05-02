#!/usr/bin/env julia

# script with a simple command line interface

# the first line allows the script to be run like an executable from the
# terminal

# The "ArgParse" framework provies a simpl framework for parsing and type
# checking arguments passed from the terminal
using ArgParse


function main(args::Dict{String,Any})
    println("string: $(args["string"])")
    println("number: $(args["number"])")
    println("flag:   $(args["flag"])")
end


# this isinteractive() check makes sure that main is not run when loading
# this script into the REPL
if !isinteractive()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--string", "-s"
            help = "some string data"
            required = true
        "--number", "-n"
            help = "any integer will do"
            arg_type = Int
            default = 7
        "--flag", "-f"
            help = "a boolean flag"
            action = :store_true
    end

    # parses julia's ARGS list based on the arg table data
    main(parse_args(s))
end


# test with terminal commands like
#
#   ./cli-argparse.jl
#   ./cli-argparse.jl -h
#   ./cli-argparse.jl -s foo
#

# test with REPL commands like
#
#   include("cli-argparse.jl")
#   main(Dict("string" => "foo", "number" => 4, "flag" => false))
#
