$gtk.ffi_misc.gtk_dlopen("golf_pixel_array")

class PXArray
  def initialize(x,y,width,height,scale,name="pixel_array")
    @ptr  = FFI::PXArray::new_pixel_array(width, height, name)
    @x, @y          = x, y
    @name = name
    @width          = width
    @height         = height
    @scale          = scale
    @render_width   = scale * width
    @render_height  = scale * height
  end

  def pixel_array_ptr
    @ptr
  end

  # def render(args)
  #   FFI::PXArray::update_pixel_array(@c_pixel_array)
  #
  # end
  def __render
    FFI::PXArray::upload_pixel_array(@ptr)
  end

  def render_as_sprite(args)
    __render
    args.outputs.sprites << {
      x: @x,
      y: @y,
      w: @render_width,
      h: @render_height,
      path: @name.to_sym
    }
  end

  def render_as_primitive(args)
    __render
    args.outputs.primitives << {
      x: @x,
      y: @y,
      w: @render_width,
      h: @render_height,
      path: @name.to_sym
    }.sprite
  end

  def clear
    FFI::PXArray::clear_pixel_array(@ptr)
  end

  def get_pixel(x,y)
    color = FFI::PXArray::get_pixel(@ptr,x,y);
    [color&0xFF, (color>>8)&0xFF, (color>>16)&0xFF]
  end

  def set_pixel(x,y,*color)
    case color.length
    when 1
      FFI::PXArray::set_pixel(@ptr, x, y, color[0])
    when 3
      FFI::PXArray::set_pixel(@ptr, x, y, 0xFF000000 | (color[2].to_byte << 16) | (color[1].to_byte << 8) | color[0].to_byte)
    when 4
      FFI::PXArray::set_pixel(@ptr, x, y, (color[3].to_byte << 24) | (color[2].to_byte << 16) | (color[1].to_byte << 8) | color[0].to_byte)
    end
  end

  def copy(x,y,source,source_x,source_y,source_w,source_h)
    if !$gtk.production
      puts "source: #{source.pixel_array_ptr}"
      puts "dest(self): #{@ptr}"
      puts "x:#{x} - y:#{y} - sx:#{source_x} - sy:#{source_y} - sw:#{source_w} - sh:#{source_h}"
    end
    FFI::PXArray::copy( source.pixel_array_ptr,
                                    @ptr,
                                    source_x,
                                    source_y,
                                    source_w,
                                    source_h,
                                    x, y )
  end
end