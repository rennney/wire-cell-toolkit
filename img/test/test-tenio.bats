#!/usr/bin/env bats

# This file is generated.  Any edits may be lost.
# See img/test/test-tenio.org for source to modify.

# standard WCT Bats support library
bats_load_library "wct-bats.sh"

function make_dag () {
    local src=$1; shift
    local tgt=$1; shift
    #declare -a args=( -A "detector=pdsp" -S "anode_iota=[0]" )
    declare -a args=( -A "detector=pdsp" )
    if [ "$src" != "depo" ] ; then
        args+=( -A "infiles=apa-%(anode)s-${src}.npz" )
    fi
    args+=( -A "outfiles=apa-%(anode)s-${tgt}.npz")
    local cfg_file="$(relative_path tenio-${src}-${tgt}.jsonnet)"
    run_idempotently -s "$cfg_file" -t "dag-${tgt}.json" -- \
        compile_jsonnet "$cfg_file" "dag-${tgt}.json" "${args[@]}"
    [[ -s dag-${tgt}.json ]]
    run_idempotently -s "dag-${tgt}.json" -t "dag-${tgt}.png" -- \
        dotify_graph "dag-${tgt}.json" "dag-${tgt}.png"
}

@test "compile configuration for depo to adc" {
    cd_tmp file
    make_dag depo adc 
}

@test "compile configuration for adc to acp" {
    cd_tmp file
    make_dag adc acp 
}

@test "compile configuration for adc to sig" {
    cd_tmp file
    make_dag adc sig 
}

@test "compile configuration for sig to img" {
    cd_tmp file
    make_dag sig img 
}

@test "compile configuration for img to ptc" {
    cd_tmp file
    make_dag img ptc 
}

function run_dag () {
    local src=$1; shift
    local tgt=$1; shift
    run_idempotently -s apa-0-${src}.npz -t apa-0-${tgt}.npz -- \
        wct -l dag-${tgt}.log -L debug dag-${tgt}.json
    local warnings=$(grep '\bW\b' dag-${tgt}.log)
    echo "$warnings" 1>&3
    local errors=$(grep '\bE\b' dag-${tgt}.log)
    [[ -z "$errors" ]]
    file_larger_than apa-0-${tgt}.npz 22
}

@test "run wire-cell stage depo to adc" {
    cd_tmp file
    run_dag depo adc 
}

@test "run wire-cell stage adc to acp" {
    cd_tmp file
    run_dag adc acp 
}

@test "run wire-cell stage adc to sig" {
    cd_tmp file
    run_dag adc sig 
}

@test "run wire-cell stage sig to img" {
    cd_tmp file
    run_dag sig img 
}

@test "run wire-cell stage img to ptc" {
    cd_tmp file
    run_dag img ptc 
}
