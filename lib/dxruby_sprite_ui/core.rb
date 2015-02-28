################################################################################
#
# SpriteUI
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

require 'dxruby'
require 'quincite'

module DXRuby

  ##############################################################################
  #
  # SpriteUI ���W���[��.
  #
  module SpriteUI

    include Quincite

    ############################################################################
    #
    # �r���_�[ DSL �����s���� UI �c���[���\�z����.
    #
    def self.build(&proc)
      UI.build(UI::ContainerBox, &proc)
    end

    ############################################################################
    #
    # SpriteUI �Ƀ��W���[�������蓖�Ă�.
    #
    def self.equip(mod)
      Base.__send__(:include, const_get(mod))
    end

    ############################################################################
    #
    # ColorUtils ���W���[��
    #
    module ColorUtils

      ##########################################################################
      #
      # ������F�z��𐶐�����.
      #
      # Params:
      #   - color :
      #
      def self.make_color(color)
        case color
        when Array
          color
        when Fixnum
          [color >> 16 & 0xff,
           color >> 8 & 0xff,
           color & 0xff]
        when /^#[0-9a-fA-F]{6}$/
          [color[1..2].hex,
           color[3..4].hex,
           color[5..6].hex]
        else
          nil
        end
      end

    end

    ############################################################################
    #
    # StyleSet �N���X.
    #
    class StyleSet

      # 
      #
      attr_reader :bg
      attr_reader :margin, :padding

      # 
      #
      attr_accessor :border_width, :border_color
      attr_accessor :width, :height
      attr_accessor :position, :top, :left, :bottom, :right
      attr_accessor :visible

      ##########################################################################
      #
      # ������.
      #
      def initialize
        @margin = [0, 0, 0, 0]
        @padding = [0, 0, 0, 0]
        @bg = nil
        @border_width = 0
        @border_color = [0, 0, 0, 0]
        @width = nil
        @height = nil
        @position = :relative
        @top = nil
        @left = nil
        @bottom = nil
        @right = nil
        @visible = true
      end

      ##########################################################################
      #
      # �w�i�F��ݒ肷��.
      #
      def bgcolor=(bgcolor)
        bgcolor = ColorUtils.make_color(bgcolor)
        if bgcolor
          @bg = Image.new(1, 1, bgcolor)
        else
          @bg = nil
        end
      end

      ##########################################################################
      #
      # �g����ݒ肷��.
      #
      def border=(border)
        case border
        when Hash
          @border_width = border[:width] || 1
          @border_color = ColorUtils.make_color(border[:color]) || [255, 255, 255]
        else
          @border_width = nil
          @border_color = nil
        end
      end

      ##########################################################################
      #
      # �}�[�W����ݒ肷��.
      #
      def margin=(*args)
        case args
        when Numeric
          @margin = [args] * 4
        when Array
          case args.size
          when 1
            @margin = args * 4
          when 2
            @margin = args * 2
          when 3
            @margin = [*args, args[1]]
          when 4
            @margin = args
          else
            @margin = args[0...4]
          end
        else
          @margin = [0, 0, 0, 0]
        end
      end

      ##########################################################################
      #
      #
      #
      def margin_top
        @margin[0]
      end

      ##########################################################################
      #
      #
      #
      def margin_right
        @margin[1]
      end

      ##########################################################################
      #
      #
      #
      def margin_bottom
        @margin[2]
      end

      ##########################################################################
      #
      #
      #
      def margin_left
        @margin[3]
      end

      ##########################################################################
      #
      # �p�f�B���O��ݒ肷��.
      #
      def padding=(args)
        case args
        when Numeric
          @padding = [args] * 4
        when Array
          case args.size
          when 1
            @padding = args * 4
          when 2
            @padding = args * 2
          when 3
            @padding = [*args, args[1]]
          when 4
            @padding = args
          else
            @padding = args[0...4]
          end
        else
          @padding = [0, 0, 0, 0]
        end
      end

      ##########################################################################
      #
      #
      #
      def padding_top
        @padding[0]
      end

      ##########################################################################
      #
      #
      #
      def padding_right
        @padding[1]
      end

      ##########################################################################
      #
      #
      #
      def padding_bottom
        @padding[2]
      end

      ##########################################################################
      #
      #
      #
      def padding_left
        @padding[3]
      end

      ##########################################################################
      #
      # ����Ԃ��擾����.
      #
      # Returns:
      # 
      #
      def visible?
        @visible
      end

    end

    ############################################################################
    #
    # Base �N���X
    #
    class Base < Sprite

      include SpriteUI
      include UI::Control

      extend Forwardable

      # 
      #
      attr_accessor :id

      # 
      #
      attr_reader :style

      # 
      #
      def_delegators :@style, :position
      def_delegators :@style, :top, :left, :bottom, :right
      def_delegators :@style, :visible?

      ##########################################################################
      #
      # ������.
      #
      def initialize(id='', *args)
        super(0, 0)
        self.id = id
        self.collision = [0, 0]
        @style = StyleSet.new
        init_control
      end

      ##########################################################################
      #
      # �w�肳�ꂽ���O�̃X�^�C�������݂��邩������s��.
      #
      # Params:
      #   - name :
      #
      # Returns:
      #   
      #
      def style_include?(name)
        @style.respond_to?("#{name}=")
      end

      ##########################################################################
      #
      # �X�^�C����ݒ肷��.
      #
      # Params:
      #   - name :
      #   - args :
      #
      def style_set(name, args)
        @style.__send__("#{name}=", args)
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̕����擾����.
      #
      def width
        if @width
          @width
        elsif @computed_width
          @computed_width
        else
          content_width
        end
      end

      ##########################################################################
      #
      # ���e���ɉ����������擾����.
      #
      def content_width
        if image
          image.width
        else
          0
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍������擾����.
      #
      def height
        if @height
          @height
        elsif @computed_height
          @computed_height
        else
          content_height
        end
      end

      ##########################################################################
      #
      # ���e���ɉ������������擾����.
      #
      def content_height
        if image
          image.height
        else
          0
        end
      end

      ##########################################################################
      #
      # �z�u��̃R���|�[�l���g�̕����擾����.
      #
      def layout_width
        case position
        when :absolute
          0
        else
          width + margin_left + margin_right
        end
      end

      ##########################################################################
      #
      # �z�u��̃R���|�[�l���g�̍������擾����.
      #
      def layout_height
        case position
        when :absolute
          0
        else
          height + margin_top + margin_bottom
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̊O���̗]�����擾����.
      #
      def margin_top
        case position
        when :absolute
          0
        else
          @style.margin[0]
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̊O���̗]�����擾����.
      #
      def margin_right
        case position
        when :absolute
          0
        else
          @style.margin[1]
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̊O���̗]�����擾����.
      #
      def margin_bottom
        case position
        when :absolute
          0
        else
          @style.margin[2]
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̊O���̗]�����擾����.
      #
      def margin_left
        case position
        when :absolute
          0
        else
          @style.margin[3]
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̓����̗]�����擾����.
      #
      def padding_top
        @style.padding[0]
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̓����̗]�����擾����.
      #
      def padding_right
        @style.padding[1]
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̓����̗]�����擾����.
      #
      def padding_bottom
        @style.padding[2]
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̓����̗]�����擾����.
      #
      def padding_left
        @style.padding[3]
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̕`��.
      #
      def draw
        if visible?
          draw_bg if @style.bg
          draw_image(x + padding_left, y + padding_top) if image
          draw_border if @style.border_width and @style.border_color
        end
      end

      ##########################################################################
      #
      # �w�i��`�悷��.
      #
      def draw_bg
        (target or Window).draw_scale(x, y, @style.bg, width, height, 0, 0)
      end

      ##########################################################################
      #
      # �g����`�悷��.
      #
      def draw_border
        draw_box(x, y, x + width, y + height, @style.border_width, @style.border_color)
      end

      ##########################################################################
      #
      # �摜��`�悷��.
      #
      def draw_image(x, y)
        (target or Window).draw(x, y, image)
      end

      ##########################################################################
      #
      # ������`�悷��.
      #
      def draw_line(x0, y0, x1, y1, width, color)
        if width == 1
          (target or Window).draw_line(x0, y0, x1 + width - 1, y1 + width - 1, color)
        else
          (target or Window).draw_box_fill(x0, y0, x1 + width - 1, y1 + width - 1, color)
        end
      end

      ##########################################################################
      #
      # ��`�̋��E����`�悷��.
      #
      def draw_box(x0, y0, x1, y1, width, color)
        draw_line(x0, y0, x1 - width, y0, width, color)
        draw_line(x0, y0, x0, y1 - width, width, color)
        draw_line(x0, y1 - width, x1 - width, y1 - width, width, color)
        draw_line(x1 - width, y0, x1 - width, y1 - width, width, color)
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍X�V.
      #
      def update
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̔z�u.
      #
      def layout(ox=0, oy=0, parent=Window)
        resize(parent)
        move(ox, oy, parent)
      end

      ##########################################################################
      #
      # �R���|�[�l���g�����̕����擾����.
      #
      def inner_width(parent)
        parent.width -
          [parent.padding_left, self.margin_left].max +
          [parent.padding_right + self.margin_right].max
      end

      ##########################################################################
      #
      # �R���|�[�l���g�����̍������擾����.
      #
      def inner_height(parent)
        parent.height -
          [parent.padding_top, self.margin_top].max +
          [parent.padding_bottom, self.margin_bottom].max
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍��W�̍X�V.
      #
      def move(to_x, to_y, parent)
        if left and Numeric === left
          case left
          when Integer
            self.x = to_x + left
          when Float
            self.x = to_x + (inner_width(parent) - self.width) * left
          end
        elsif right and Numeric === right
          case right
          when Integer
            self.x = to_x + inner_width(parent) - self.width - right
          when Float
            self.x = to_x - (inner_width(parent) - self.width) * (right - 1)
          end
        else
          self.x = to_x
        end
        if top and Numeric === top
          case top
          when Integer
            self.y = to_y + top
          when Float
            self.y = to_y + (inner_height(parent) - self.height) * top
          end
        elsif bottom and Numeric === bottom
          case bottom
          when Integer
            self.y = to_y + inner_height(parent) - self.height - bottom
          when Float
            self.y = to_y - (inner_height(parent) - self.height) * (bottom - 1)
          end
        else
          self.y = to_y
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̗̈�̍X�V.
      #
      def resize(parent)
        case @style.width
        when Integer
          @width = @style.width
        when Float
          @width = parent.width * @style.width
        when :full
          @width = parent.width -
            [parent.margin_left, self.margin_left].max +
            [parent.margin_right, self.margin_right].max
        else
          @width = nil
        end
        case @style.height
        when Integer
          @height = @style.height
        when Float
          @height = parent.height * @style.height
        when :full
          @height = parent.height -
            [parent.margin_top, self.margin_top].max +
            [parent.margin_bottom, self.margin_bottom].max
        else
          @height = nil
        end
      end

      ##########################################################################
      #
      # �ڐG����̈�̍X�V.
      #
      def update_collision
        self.collision = [0, 0, self.width, self.height]
      end

    end

    ############################################################################
    #
    # Container �N���X.
    #
    class Container < Base

      include UI::Container

      ##########################################################################
      #
      # ������.
      #
      def initialize(*args)
        super
        init_container
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̕`��.
      #
      def draw
        super
        components.each(&:draw) if visible?
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍X�V.
      #
      def update
        super
        components.each(&:update)
      end

    end
  end
end
