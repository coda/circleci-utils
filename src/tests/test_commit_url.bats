# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/get_lkg_hash.sh
}

@test '1: Get a Diff URL' {
    #Just make sure no error; first branch will have no commit comparison
    result=$(run_main)
    [[ "$result" != *"Error"* ]]
}