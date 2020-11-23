# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/get_lkg_hash.sh
}

@test '1: Get a Diff URL' {
    result=$(run_main)
    [[ "$result" == *"https://github.com/kr-project"* ]]
}