#!/usr/bin/env bats

# Make "comp1d" plots over recent history.

bats_load_library wct-bats.sh

# bats file_tags=report

function comp1d () {

    local src=$1; shift
    local infile="$1"; shift
    local kind=$1; shift
    local iplane=$1; shift

    local past=( $(historical_files --current -l 3 $infile) )


    local letters=("u" "v" "w")
    local chmins=(0 800 1600)
    local chmaxs=(800 1600 2560)
    local letter=${letters[$iplane]}
    local fig="${src}-${kind}-${letter}.png"

    declare -a args=( -s -n "$kind" --transform ac )
    args+=( --chmin ${chmins[$iplane]} --chmax ${chmaxs[$iplane]} )
    if [ "$src" = noise ] ; then
        args+=( --tier '*' )
    else
        args+=( --tier 'orig' )
    fi
    args+=( -o "$fig" )

    yell "ARGS: ${args[@]}"

    for one in ${past[@]}
    do
        deps+=( -s "$one" )
    done

    local wcplot=$(wcb_env_value WCPLOT)
    run_idempotently ${deps[@]} -t "$fig" -- $wcplot comp1d "${args[@]}" ${past[@]}
    [[ -s "$fig" ]]
    saveout -c reports "$fig"
}

@test "pdsp comp1d" {
    cd_tmp

    # The list of files that can be comp1d'ed.  These must be PDSP APA0
    declare -A inputs
    inputs[noise]="test-addnoise/test-addnoise-empno-6000.tar.gz"
    inputs[simsn]="test-pdsp-simsn/frames-adc.tar.gz"

    yell "INPUT KEYS: ${!inputs[@]}"
    yell "INPUT VALS: ${inputs[@]}"

    for src in "${!inputs[@]}"
    do
        local infile="${inputs[$src]}"
        for kind in wave spec
        do
            for ipln in 0 1 2
            do
                comp1d $src $infile $kind $ipln
            done
        done
    done
}
