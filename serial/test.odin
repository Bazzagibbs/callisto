package callisto_serial

import "core:testing"
import "core:image"
import "core:strings"
import "core:io"
import "core:os/os2"


@(test)
test_marshal :: proc(t: ^testing.T) {

        Test_Image_Channels :: enum {
                R,
                RG,
                RGBA,
        }


        Test_Image :: struct {
                data         : []u8,
                channels     : Test_Image_Channels,
                channel_size : u8,
        }

        Test_Asset_Image_Wrapper :: struct {
                name           : string,
                uuid           : u128,
                embedded_image : Test_Image,
        }


        test_asset := Test_Asset_Image_Wrapper {
                name = "This is a test asset",
                uuid = 7777888899990000,
                embedded_image = {
                        data = {11, 22, 33, 44, 55, 66, 77, 88, 99, 00, 11, 22},
                        channels = .RGBA,
                        channel_size = 8,
                },
        }


        b: strings.Builder
        strings.builder_init(&b)
        defer strings.builder_destroy(&b)

        w := strings.to_writer(&b)

        testing.expect(t, marshal_into_writer(w, &test_asset) == nil)

        testing.expect(t, os2.write_entire_file("test_result.cal", b.buf[:]) == nil)
}
