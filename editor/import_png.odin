package callisto_editor

@(init)
register_importer_png :: proc() {
        // May later require further processing
        // - compression
        // - normal map format
        // - sprite sheets from image
        // - image to atlas
        register_importer(".png", import_copy)
}
