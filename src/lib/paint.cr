require "opengl"
require "lib_glut"
require "./canvas"
require "./tools/color_palette"
require "./tool_selector"

# LABELS_BUTTON(x) ((x) ? 'R' : 'L')
# LABELS_CLICK(x) ((x) ? 'U' : 'D')

class Paint
  @canvas : Canvas
  @palette : Tools::ColorPalette
  @width : Int32
  @height : Int32
  @debug_ = true
  selector = ToolSelector

  def initialize(@height, @width)
    selector_width = 70
    pallete_width = 80
    canvas_width = 940
    @canvas = Canvas.new(canvas_width, height)
    @backup = Image.new(@canvas.canvas)
    @palette = Tools::ColorPalette.new(@canvas, @backup,
      @width - canvas_width - selector_width, @height,
      canvas_width + selector_width, 0)
    @palette.base = @canvas.selected
    @selector = ToolSelector.new(@canvas, @backup,
      selector_width, @height // 2,
      canvas_width, @height // 2)
  end

  def palette_click(x, y)
    @palette.clicked(x, y)
  end

  def tools_click(x, y)
    @selector.clicked(x, y)
  end

  def heartbeat
    @selector.selected.heartbeat
    render
  end

  def render
    @selector.selected.render
    @selector.render
    @palette.render
    LibGL.flush
    LibGLUT.swap_buffers
  end

  def debug(msg)
    puts msg if @debug_
  end

  def eventoClick(b, e, x, y)
    y = @height - y
    if palette_click(x, y)
      @palette.on_click(b, e, x, y)
    elsif tools_click(x, y)
      @selector.on_click(b, e, x, y)
    else
      @selector.selected.on_click(b, e, x, y)
    end
    LibGLUT.post_redisplay
  end

  def eventoArrastre(x, y)
    # debug("M #{x} #{height - y}"
    @selector.selected.on_motion(x, @height - y)
    LibGLUT.post_redisplay
  end

  def eventoTeclado(k, x, y)
    case k
    when "R"
      @canvas.canvas = @canvas.canvas.gray_scale
    when "X"
      @canvas.canvas = @canvas.canvas.x_derivative
    when "Y"
      @canvas.canvas = @canvas.canvas.y_derivative
    when "D"
      @canvas.canvas = @canvas.canvas.derivative
      # when "T"
      #   @canvas.canvas = @canvas.canvas.threshold

      # when "G"
      #   @canvas.canvas = @canvas.canvas.gaussian_filter

      # when "S"
      #   @canvas.canvas = @canvas.canvas.sharpen_filter

      # when "B"
      #   @canvas.canvas = @canvas.canvas.blur_filter

      # when "E"
      #   @canvas.canvas = @canvas.canvas.erode

      # when "I"
      #   @canvas.canvas = @canvas.canvas.dilate

      # when "L"
      #   @canvas.canvas = @canvas.canvas.laplace

    when 3, 27, 23, 17
      LibGLUT.leave_main_loop

    when 16
      @canvas.load_bmp("bitmap/big.bmp")
      @selector.selected.make_backup
    when 7
      @canvas.load_bmp("bitmap/catedral.bmp")
      @selector.selected.make_backup
    else
      puts k
    end
  end
end
# endif
