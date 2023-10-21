package callisto_asset

import cc "../common"

// Construct is a transform hierarchy with a fixed number of nodes.
// Constructs can only be extended by using Hardpoints.
Construct :: struct {
    hierarchy: []cc.Transform
}

make_construct :: proc(node_count: int) -> Construct {
    construct: Construct
    construct.hierarchy = make([]cc.Transform, node_count)
    return construct
}

delete_construct :: proc(construct: ^Construct) {
    delete(construct.hierarchy)
}
