package callisto_editor

// Walk res directory
// If a file exists with no metadata file, create a default one for that file type
// Create a .cal file containing all resources created from a source file
//      - Manifest contains additional URIs to subresources 
//      - File player.cal has subresources "frame_0", "frame_1", etc. and would be referenced by `player_resource := Resource[Sprite]("res://sprites/player.cal:frame_0")`

