# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/get_lkg_hash.sh
}

@test '1: Get a Diff URL' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    result=$(run_main)
    [[ "$result" == *"https://github.com/kr-project"* ]]
}