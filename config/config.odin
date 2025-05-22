package callisto_config

APP_NAME     :: #config(APP_NAME, "calllisto app")
COMPANY_NAME :: #config(COMPANY_NAME, "callisto default company")

HOT_RELOAD   :: #config(HOT_RELOAD, false)

NO_ASSET_TYPE_CHECK :: #config(NO_ASSET_TYPE_CHECK, false)

MAX_SUBMESHES :: #config(MAX_SUBMESHES, 16) // Maximum number of material groups per mesh.
MAX_TEXTURES :: #config(MAX_TEXTURES, 16)   // Maximum number of textures per shader stage in a material.
