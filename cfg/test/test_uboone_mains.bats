#!/bin/bash

# Test some main jsonnet that are expected to compile w/out args

bats_load_library wct-bats.sh

@test "compile various main configs" {

    cd_tmp

    local mains=(wct-jsondepo-sim-nf-sp.jsonnet
                 wct-sim-check.jsonnet
                 wct-sim-deposplat.jsonnet
                 wct-sim-zipper-check.jsonnet
                 wcls-sim-drift.jsonnet
                 wcls-sim-drift-simchannel.jsonnet
                 wcls-sim.jsonnet
                 wcls-sim-nf-sp.jsonnet
                 wct-sim-ideal-sig.jsonnet
                 wct-sim-ideal-sn-nf-sp.jsonnet)

    for main in ${mains[*]}
    do
        local cfgfile="$(config_path pgrapher/experiment/uboone/$main)"
        [[ -s "$cfgfile" ]]
        local jsonfile="$(basename $cfgfile .jsonnet).json"

        t1=$(date +%s)
        compile_jsonnet "$cfgfile" "$jsonfile"
        t2=$(date +%s)
        dt=$(( $t2 - $t2 ))
        echo "$jsonfile took $dt seconds"
        [[ $dt -le 2 ]]

        if [ -z "$(wcb_env_value WCPGRAPH)" ] ; then
            continue;
        fi

        local svgfile="$(basename $jsonfile .json).svg"
        dotify_graph "$jsonfile" "$svgfile"
        saveout $svgfile
    done

}    
