require "mygame/boot"

# トランプのカードと山札のモジュール
module CardDeck

  # トランプのクラス
  class Card
    SCALE = 0.5
    CARD_W = 200 * SCALE
    CARD_H = 300 * SCALE

    # クラスメソッド
    class << self
      def suits
        %w( Spades Clubs Diamonds Hearts )
      end

      # 裏面をカードの情報と無関係に表示する
      def back(x, y)
        back_card = Image.new("images/uraaka.png")
        back_card.x = x
        back_card.y = y
        back_card.scale = SCALE
        back_card
      end
    end

    # インスタンスメソッド
    def initialize(suit, number)
      @suit = Card.suits[suit]
      @number = number
      @image = Image.new("images/#{@suit[0].downcase}#{@number}.png")
      @scale = SCALE
      @image.scale = @scale
      @width = CARD_W
      @height = CARD_H
      @face = true
      @clicked = false
    end

    def render
      @image.render
    end

    def x=(value)
      @image.x = value
    end

    def x
      @image.x
    end

    def y=(value)
      @image.y = value
    end

    def y
      @image.y
    end

    def scale=(value)
      @image.scale = value
    end

    # めくる
    def turn
      x = @image.x
      y = @image.y

      @image =
        case @face
        when true then Image.new("images/uraaka.png")
        else Image.new("images/#{@suit[0].downcase}#{@number}.png")
        end

      @image.x = x
      @image.y = y
      @face = @face ? false : true
      @image.scale = @scale
    end

    def clicked?(event)
      # 比率を変えると(0, 0)の位置が画像左上から真ん中になるのを修正
      image_x = @image.x - @width * SCALE
      image_y = @image.y - @height * SCALE

      click_x = (image_x..image_x+@width).include?(event.x)
      click_y = (image_y..image_y+@height).include?(event.y)
      click_x and click_y
    end

    def click
      @clicked = @clicked ? false : true
    end


    alias display render

    attr_reader :number, :suit, :clicked, :face
  end


  # 山札のクラス
  class Deck
    def initialize
      reset
    end

    # 52枚のトランプオブジェクトを格納してシャッフル
    def reset
      @cards = []
      4.times {|suit| (1..13).each {|num| @cards << Card.new(suit, num)}}
      @cards.shuffle!
    end

    def draw
      @cards.shift
    end

    # Deckのインスタンスを配列みたいに扱えるように
    def size
      @cards.size
    end

    def [](value)
      @cards[value]
    end

    def shuffle!
      @cards.shuffle!
    end

    alias length size
    alias deal draw
    alias shuffle shuffle!
  end
end
