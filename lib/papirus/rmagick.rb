require 'rmagick'

class Magick::Image
    # Send's any image to the PAPiRus display, if it is found
    # image is rescaled to fit the display (positioning it mid center)
    # @param display[PaPiRus::Display] The {PaPiRus::Display} object
    def to_papirus(display)
        # Resize to fit the screen
        resized = resize_to_fit(display.width, display.height)
        # Reduce the image to a limited number of colors for a "poster" effect, brings it donw to 4-bit 16 colors
        posterized = resized.posterize(2)
        #now, as the display expects a file with all pixels set, we need to extend the image to the display size
        #if it is smaller in either width or height or both
        if (posterize.columns != display.width or posterize.rows != display.height)
            # extent fill color
            posterized.background_color = "#FFFFFF"
            # calculate necessary translation to center image on background
            x = (posterized.columns - display.width) / 2
            y = (posterized.rows - display.height) / 2
            # now, 'extent' the image to the correct size with the image centered
            posterized = posterized.extent(display.width, display.height, x, y)
        end
        # Now, make grayscale with only 2 colors, b/w, brings it down to 1-bit 2 colors
        quantized = posterized.quantize(2, Magick::GRAYColorspace)
        #return the raw image data
        quantized.write(display.display_path){self.format='DIB'} #DIB=Device Independant Binary, as in , no headers, just raw data
    end
end
