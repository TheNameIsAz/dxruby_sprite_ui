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
      attr_accessor :break_after

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
        @break_after = false
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
      def margin=(args)
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

      ##########################################################################
      #
      # �u���[�N�|�C���g�̗L�����擾����.
      #
      # Returns:
      # 
      #
      def break_after?
        @break_after
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
      def_delegators :@style, :padding_top, :padding_bottom
      def_delegators :@style, :padding_left, :padding_right
      def_delegators :@style, :bg
      def_delegators :@style, :border_width, :border_color
      def_delegators :@style, :visible?
      def_delegators :@style, :break_after?

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
          @style.margin_top
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
          @style.margin_right
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
          @style.margin_bottom
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
          @style.margin_left
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̕`��.
      #
      def draw
        if visible?
          draw_bg if bg
          draw_image(x + padding_left, y + padding_top) if image
          draw_border if border_width and border_color
        end
      end

      ##########################################################################
      #
      # �w�i��`�悷��.
      #
      def draw_bg
        (target or Window).draw_scale(x, y, bg, width, height, 0, 0)
      end

      ##########################################################################
      #
      # �g����`�悷��.
      #
      def draw_border
        draw_box(x, y, x + width, y + height, border_width, border_color)
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
        x1 += width - 1
        y1 += width - 1
        if width == 1
          (target or Window).draw_line(x0, y0, x1, y1, color)
        else
          (target or Window).draw_box_fill(x0, y0, x1, y1, color)
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
      def layout(ox=0, oy=0, parent=DXRuby::Window)
        resize(parent)
        move(ox, oy, parent)
      end

      ##########################################################################
      #
      # �R���|�[�l���g�����̕����擾����.
      #
      def inner_width(parent)
        if parent == DXRuby::Window
          parent.width - (self.margin_left + self.margin_right)
        else
          parent.width -
            ([parent.padding_left, self.margin_left].max +
             [parent.padding_right, self.margin_right].max)
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�����̍������擾����.
      #
      def inner_height(parent)
        if parent == DXRuby::Window 
          parent.height - (self.margin_top + self.margin_bottom)
        else
          parent.height -
            ([parent.padding_top, self.margin_top].max +
             [parent.padding_bottom, self.margin_bottom].max)
        end
      end

      ##########################################################################
      #
      # �R���|�[�l���g�̍��W�̍X�V.
      #
      def move(to_x, to_y, parent)
        move_x(to_x, parent)
        move_y(to_y, parent)
      end

      ##########################################################################
      #
      # �R���|�[�l���g�� x ���W�̍X�V.
      #
      # Private
      #
      def move_x(to_x, parent)
        if position == :absolute
          if left and Numeric === left
            case left
            when Fixnum
              self.x = to_x + left
            when Float
              self.x = to_x + (parent.width - self.width) * left
            end
          elsif right and Numeric === right
            case left
            when Fixnum
              self.x = to_x + parent.width - self.width - right
            when Float
              self.x = to_x + (parent.width - self.width) * (right - 1)
            end
          else
            self.x = to_x
          end
        else
          if left and Numeric === left
            self.x = to_x + left
          elsif right and Numeric === right
            self.x = to_x + inner_width(parent) - self.width - right
          else
            self.x = to_x
          end
        end
      end
      private :move_x

      ##########################################################################
      #
      # �R���|�[�l���g�� y ���W�̍X�V.
      #
      # Private
      #
      def move_y(to_y, parent)
        if position == :absolute
          if top and Numeric === top
            case top
            when Fixnum
              self.y = to_y + top
            when Float
              self.y = to_y + (parent.height - self.height) * top
            end
          elsif bottom and Numeric === bottom
            case bottom
            when Fixnum
              self.y = to_y + parent.height - self.height - bottom
            when Float
              self.y = to_y + (parent.height - self.height) * (bottom - 1)
            end
          else
            self.y = to_y
          end
        else
          if top and Numeric === top
            self.y = to_y + top
          elsif bottom and Numeric === bottom
            self.y = to_y + inner_height(parent) - self.height - bottom
          else
            self.y = to_y
          end
        end
      end
      private :move_y

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
          @width = inner_width(parent)
        else
          @width = nil
        end
        case @style.height
        when Integer
          @height = @style.height
        when Float
          @height = parent.height * @style.height
        when :full
          @height = inner_height(parent)
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
