package callisto_tests_common

import "core:testing"
import "core:fmt"

TEST_count := 0
TEST_fail := 0

when ODIN_TEST {
    expect  :: testing.expect
    log     :: testing.log
} else {
    expect  :: proc(t: ^testing.T, condition: bool, message: string, loc := #caller_location) -> bool {
        TEST_count += 1
        if condition == false {
            TEST_fail += 1
            fmt.printf("[%v] %v\n", loc, message)
        }

        return condition
    }
    
    log     :: proc(t: ^testing.T, v: any, loc := #caller_location) {
        fmt.printf("[%v] log: %v\n", loc, v)
    }
}
