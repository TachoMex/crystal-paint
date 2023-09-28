require "./tools/pen"
require "./tools/line"
require "./tools/eraser"
require "./tools/circle"
require "./tools/ellipse"
require "./tools/spray"
require "./tools/polygon"
require "./tools/star"
require "./tools/heart"
require "./tools/filler"
require "./tools/curve"
require "./tools/cut"

class ToolSelector < Tools::ButtonPalette
  @toolkit : Array(Tools::Base)
  @selected : Tools::Base

  property selected

  def initialize(c, b, w, h, x, y)
    @toolkit = [] of Tools::Base
    super(c, b, w, h, x, y)
    @toolkit << Tools::Pen.new(@canvas, @backup)
    @toolkit << Tools::Line.new(@canvas, @backup)
    @toolkit << Tools::Eraser.new(@canvas, @backup)
    @toolkit << Tools::Circle.new(@canvas, @backup)
    @toolkit << Tools::Ellipse.new(@canvas, @backup)
    @toolkit << Tools::Polygon.new(@canvas, @backup)
    @toolkit << Tools::Star.new(@canvas, @backup)
    @toolkit << Tools::Heart.new(@canvas, @backup)
    @toolkit << Tools::Filler.new(@canvas, @backup)
    @toolkit << Tools::Curve.new(@canvas, @backup)
    @toolkit << Tools::Spray.new(@canvas, @backup)
    @toolkit << Tools::Cut.new(@canvas, @backup)
    @total_tools = 12
    @selected = @toolkit[0]
  end

  def render
    render_background
    LibGL.color_3ub(255, 255, 255)
    (0...@total_tools).each do |i|
      if @toolkit[i] == selected
        LibGL.color_3ub(0, 0, 0)
        render_tool(i)
        LibGL.color_3ub(255, 255, 255)
      else
        render_tool(i)
      end
    end
  end

  def on_click(b, e, x, y)
    if (b == LibGLUT::LEFT_BUTTON && e == LibGLUT::UP)
      tool_clicked = clicked_button(x, y)
      if tool_clicked >= 0
        @selected = @toolkit[tool_clicked]
        @selected.make_backup
        puts "Selected: #{selected.class.name}"
      end
    end
  end
end

# endif  // LIB_TOOL_SELECTOR_H_
