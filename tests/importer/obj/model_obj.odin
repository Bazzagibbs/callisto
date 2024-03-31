package callisto_tests_importer_obj

// import "core:testing"
// import "core:fmt"
// import "core:os"
// import "core:log"
// import "core:runtime"
// // import "../../../importer"
// import "../../../asset"
//
// TEST_count := 0
// TEST_fail := 0
//
// when ODIN_TEST {
//     expect  :: testing.expect
//     log     :: testing.log
// } else {
//     expect  :: proc(t: ^testing.T, condition: bool, message: string, loc := #caller_location) -> bool {
//         TEST_count += 1
//         if condition == false {
//             TEST_fail += 1
//             fmt.printf("[%v] %v\n", loc, message)
//         }
//
//         return condition
//     }
//     
//     log     :: proc(t: ^testing.T, v: any, loc := #caller_location) {
//         fmt.printf("[%v] log: %v\n", loc, v)
//     }
// }
//
//
// main :: proc() {
//     t := testing.T{}
//
// }
//
// @test
// load_cube_obj :: proc(t: ^testing.T) {
//     cube_path := "resources/models/cube.obj"
//     cube_data, ok := os.read_entire_file(cube_path)
//     defer delete(cube_data)
//     if expect(t, ok, "Failed to read file") do return
//
//     mesh:       asset.Mesh
//     material:   asset.Material
//     mesh, material, ok = importer.parse_obj_data(cube_data) 
//     defer {
//         asset.delete(&mesh)
//         asset.delete(&material)
//     }
//     if expect(t, ok, "Failed to parse file data") do return
// }
