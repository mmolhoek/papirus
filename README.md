# papirus

ruby gem to talk to the [PaPiRus](https://www.pi-supply.com/?s=papirus&post_type=product&tags=1&limit=5&ixwps=1) display

before you start playing make sure you got the edp-fuse setup

## epaper fuse driver installation instructions (if you have not done that already ::)
```bash
sudo apt-get install libfuse-dev -y

git clone https://github.com/repaper/gratis.git
cd gratis
make rpi EPD_IO=epd_io.h PANEL_VERSION='V231_G2'
make rpi-install EPD_IO=epd_io.h PANEL_VERSION='V231_G2'
systemctl enable epd-fuse.service
systemctl start epd-fuse
```

You can find more detailed instructions [https://github.com/repaper/gratis](here)

## gem installation

```bash
$ gem install papirus
```
## usage

```ruby
require 'papirus'

# first we get ourself a display
display = PaPiRus::Display.new()
```

# Playing with Chunky_PNG
```ruby
irb
require 'papirus'
require 'papirus/chunky' # add's to_bit_stream function to chucky

#lets get a clean png of the size of the display to play with using chunky_png
image = ChunkyPNG::Image.new(display.width, display.height, ChunkyPNG::Color::WHITE)
#and we draw a circle on it which is about the size of the screen
image.circle(display.width/2, display.height/2, display.height/2-2)
```

have a look at [chunky_png](https://github.com/wvanbergen/chunky_png/wiki) for more examples

```ruby
#and last we dump the image as bitsteam to the display
display.show(image.to_bit_stream)

# now we could also change the circle and fast update the screen
image.replace!(ChunkyPNG::Image.new(display.width, display.height, ChunkyPNG::Color::WHITE))
image.circle(display.width/2, display.height/2, display.height/4)
display.show(image.to_bit_stream, 'F')

# or update the screen for multiple circles
display.clear
2.step(image.height/2-2, 5).each do |radius|
    image.replace!(ChunkyPNG::Image.new(display.width, display.height, ChunkyPNG::Color::WHITE))
    image.circle(display.width/2, display.height/2, radius)
    display.show(image.to_bit_stream, 'F')
end
```

## there are multiple screen commands ['F', 'P', 'U', 'C']

Full update (with screen cleaning):

```display.show(image.to_bit_stream); display.update``` or

```display.show(image.to_bit_stream, 'U')```

Fast update:

```display.show(image.to_bit_stream); display.fast_update```
```display.show(image.to_bit_stream, 'F')```

Partial update:

```display.show(image.to_bit_stream); display.partial_update``` or

```display.show(image.to_bit_stream, 'P')```

## Load an image from a png file with convert and chunky

First, let's use Image Magick's `convert` tool to convert any image into a b/w image the way the diplay likes it
```bash
convert in.jpg -resize '264x176' -gravity center -extent '264x176' -colorspace gray  -colors 2 -type bilevel out.png
```

Where
* the -resize scales the image to fit the display
* The -gravity and -extent combination (order is important!) makes sure the image stays at the size of the display and in the centre
* The -colorspace -colors -type combi makes the image a 1-bit grayscale b/w image

Then we use chucky with our extension to show

```ruby
irb
require 'papirus'
require 'papirus/chunky'
display = PaPiRus::Display.new()
image = ChunkyPNG::Image.from_file('out.png')
display.show(image.to_bit_stream(true))
```

# Playing with RMagic (does not work yet), did not figure out right command

```ruby
require 'papirus'
require 'rmagick'

display = PaPiRus::Display.new()
img = Magick::Image::read('/path/to/img/file.(png|jpg|etc').first
resized = img.resize_to_fit(display.width, display.height).quantize(2, Magick::GRAYColorspace)
resized.background_color = "#FFFFFF"
x = (resized.columns - display.width) / 2                # calculate necessary translation to center image on background
y = (resized.rows - display.height) / 2
resized = resized.extent(display.width, display.height, x, y)    # 'extent' fills out the resized image if necessary, with the background color, to match the full requested dimensions
resized.write(File.join([display.epd_path,'LE', 'display'])) { self.image_type = Magick::BilevelType}
display.update

# we have to translate it to a 2 bit grayscale as that is what our PaPiRus understands
display.show(img.resize_to_fit(display.width, display.height).quantize(2, Magick::GRAYColorspace).to_blob())
```

## Testing without a PAPiRus display

If you want to test the gem, but don't have your PaPiRus available, you can do the following

* clone this repo
* run the createtestepd.sh script that is in the repo which creates the needed files and folders in /tmp/epd
* start irb
* require 'papirus'
* display = PaPiRus::Display.new(epd_path: '/tmp/epd')
* play with the examples above
* when you run `display.show` the **fake** display /tmp/epd/LE/display is filled with your image
* now you can use a bin editor like xxd to have a look at the result: `xxd -b /tmp/epd/LE/display`

## TODO

* make the image.to_bit_stream routine faster (as it is now to slow to do animations with partial updates)
* add support for reading the temperature of the display
* add support for changing the update rate
* make load png image with chunky_png work (now output is black)
* make a display.load(image) that takes multiple formats and figures out how to present them
* create an issue to add your own requests :)

## Other resources

* [pi supply python driver](https://github.com/PiSupply/PaPiRus)
