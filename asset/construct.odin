package callisto_asset

import cc "../common"

// Construct is a transform hierarchy with a fixed number of nodes.
// Constructs can only be extended by using Hardpoints.
Construct :: struct {
    hierarchy:  []Node,
    dirty:      bool,
}

Node :: struct {
    userdata:    rawptr, // TODO(galileo): replace with Entity reference. This is just used for mesh asset reference for now.
    transform:   cc.Transform,
    parent:      int,
    children:    []int,
    descendents: []int,
}


make_construct :: proc(node_count: int) -> Construct {
    construct: Construct
    construct.hierarchy = make([]Node, node_count)
    return construct
}

delete_construct :: proc(construct: ^Construct) {
    delete(construct.hierarchy)
}
