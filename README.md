# papirus

Ruby gem to talk to the [PaPiRus](https://www.pi-supply.com/?s=papirus&post_type=product&tags=1&limit=5&ixwps=1) display from a Raspberry PI

Before you start playing make sure you got the display driver installed (gratis/edp-fuse) on your PI

```bash
ssh yourpi
sudo apt-get install libfuse-dev -y

git clone https://github.com/repaper/gratis.git
cd gratis
make rpi EPD_IO=epd_io.h PANEL_VERSION='V231_G2'
make rpi-install EPD_IO=epd_io.h PANEL_VERSION='V231_G2'
systemctl enable epd-fuse.service
systemctl start epd-fuse
```

You can find more detailed instructions and updates at the [gratis](https://github.com/repaper/gratis) repo

## gem installation (add sudo if your not using [RVM](https://rvm.io/))

```bash
$ gem install papirus
```

# Using with RMagic

First install rmagick

```bash
$ # Install native Image Magick library
$ (OSX) brew install imagemagick@6 && brew link imagemagick@6 --force
$ (debian/ubuntu) sudo apt-get install imagemagick
$ (Windows) no idea (did not use windows for 20 years, and would like to add some more)
$ # Install the gem that talks to the native Image Magick library
$ gem install rmagick
```

## Using an irb session to play around:

```
$ irb
require 'papirus'
require 'papirus/rmagick'
display = PaPiRus::Display.new()
image = Magick::Image::read('/path/to/img/file.[png|jpg|etc]').first
display.show(data: image.to_bit_stream(display.width, display.height))
```

# Using with ChunkyPNG

```bash
# install on
$ (OSX) brew install chunky_png
$ (debian/ubuntu) sudo apt-get install chunky_png
$ (Windows) no idea (did not use windows for 20 years, and would like to add some more)
$ gem install chunky_png
```

## Load an image from a png file

```ruby
$ irb
require 'papirus'
require 'papirus/chunky'
display = PaPiRus::Display.new()
image = ChunkyPNG::Image.from_file('out.png')
display.show(data: image.to_bit_stream(display.width, display.height))
```

The only problem here is the aspect ration of the image is not ok anymore. is a todo
But for now you could also use Image magick's convert tool to rescale  the image and place it in the middle

First, let's use Image Magick's `convert` tool to convert any image into an scaled, centered png

```bash
convert in.jpg -resize '264x176' -gravity center -extent '264x176' out.png
```

now, load it like explaned above and the image should be in the right aspect ration

## Drawing circles with ChunkyPNG

```
irb
require 'papirus'
require 'papirus/chunky' # add's to_bit_stream function to chucky

#lets get a clean png of the size of the display to play with using chunky_png
image = ChunkyPNG::Image.new(display.width, display.height, ChunkyPNG::Color::WHITE)
#and we draw a circle on it which is about the size of the screen
image.circle(display.width/2, display.height/2, display.height/2-2)
```

have a look at [chunkypng](https://github.com/wvanbergen/chunky_png/wiki) for more examples

```
#and last we dump the image as bitsteam to the display
display.show(data: image.to_bit_stream)

# now we could also change the circle and fast update the screen
image.replace!(ChunkyPNG::Image.new(display.width, display.height, ChunkyPNG::Color::WHITE))
image.circle(display.width/2, display.height/2, display.height/4)
display.show(data: image.to_bit_stream, 'F')

# or update the screen for multiple circles
display.clear
2.step(image.height/2-2, 5).each do |radius|
    image.replace!(ChunkyPNG::Image.new(display.width, display.height, ChunkyPNG::Color::WHITE))
    image.circle(display.width/2, display.height/2, radius)
    display.show(data: image.to_bit_stream, command: 'F')
end
```

## there are multiple screen commands ['F', 'P', 'U', 'C']

Full update (with screen cleaning):

```
display.show(data: image.to_bit_stream(display.width, display.height))
```

Fast update:

```
display.show(data: image.to_bit_stream(display.width, display.height)), command: 'F')
```

Partial update:

```
display.show(data: image.to_bit_stream(display.width, display.height), command: 'P')
```

## Testing without a PaPiRus display

If you want to test the gem, but don't have your PaPiRus available, you can do the following

 clone this repo

```
$ bundle exec irb -r ./lib/papirus
# The gem will create the epd_path test folder (the folder needs to be somwhere in /tmp/) and will set it by default to the 2.0 panel
display = PaPiRus::Display.new(options:{epd_path: '/tmp/epd'})
# When you want to add the 2.7 display panel, you would do
display = PaPiRus::Display.new(options:{epd_path: '/tmp/epd', width: 264, height: 176, panel: 'EPD 2.7'})
```

Now play with the examples above

* when you run `display.show` the **fake** display /tmp/epd/LE/display is filled with your image
* now you can use a bin editor like xxd to have a look at the result: `xxd -b /tmp/epd/LE/display`
* or, use `image.inspect_bitstream(display.width, display.height)` to dump the image as 1's and 0's to the terminal
* make sure you have your terminal font small enought so the image fits the terminal :)

## handy convert command

This Image Magick convert command creates a 1-bit 2-color png

```bash
convert in.jpg -resize '264x176' -gravity center -extent '264x176' -colorspace gray  -colors 2 -type bilevel out.png
```

Where
* the -resize scales the image to fit the display
* The -gravity and -extent combination (order is important!) makes sure the image stays at the size of the display and in the centre
* The -colorspace -colors -type combi makes the image a 1-bit grayscale b/w image

## TODO

* add support for reading the temperature of the display
* add support for changing the update rate
* make load png image with chunky_png scale keeping aspect ratio in mind
* create an issue to add your own requests :)

## Other resources

* [pi supply python driver](https://github.com/PiSupply/PaPiRus)

## Development

* Install bundler with ```gem install bundler```
* Run ```bundle install``` to get all the gems
* Create the documentation with: ```bundle exec yard```
* Run the tests with: ```bundle exec rake yard:doctest```

## Contributing to papirus

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add unit tests for it. This is important so I don't break it in a future version unintentionally.
* Create a PR

## Copyright

Copyright (c) 2017 Mischa Molhoek. See LICENSE.txt for further details.
